'use strict';
const cache = require('memory-cache');
const CacheAsideService = require('./cacheAsideService');
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';

class TodoController {
    constructor({tracer, redisClient, logChannel}) {
        this._tracer = tracer;
        this._redisClient = redisClient;
        this._logChannel = logChannel;
        // Inicializar Cache-Aside service
        this._cacheService = new CacheAsideService(redisClient, 600); // 10 minutos TTL
    }

    // Implementación Cache-Aside para listar todos
    async list (req, res) {
        try {
            const username = req.user.username;
            const cacheKey = this._cacheService.generateCacheKey('todos', username, 'list');
            
            // Usar Cache-Aside pattern
            const data = await this._cacheService.getWithCacheAside(
                cacheKey,
                () => {
                    // Data fetcher: obtener de la fuente original (memoria en este caso)
                    return this._getTodoData(username);
                }
            );

            res.json(data.items);
        } catch (error) {
            console.error('[TodoController] Error in list:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create (req, res) {
        try {
            const username = req.user.username;
            
            // TODO: must be transactional and protected for concurrent access, but
            // the purpose of the whole example app it's enough
            const data = this._getTodoData(username);
            const todo = {
                content: req.body.content,
                id: data.lastInsertedID
            };
            data.items[data.lastInsertedID] = todo;

            data.lastInsertedID++;
            this._setTodoData(username, data);

            // Invalidar cache después de crear
            const cacheKey = this._cacheService.generateCacheKey('todos', username, 'list');
            await this._cacheService.invalidateCache(cacheKey);

            this._logOperation(OPERATION_CREATE, username, todo.id);

            res.json(todo);
        } catch (error) {
            console.error('[TodoController] Error in create:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async delete (req, res) {
        try {
            const username = req.user.username;
            const data = this._getTodoData(username);
            const id = req.params.taskId;
            
            delete data.items[id];
            this._setTodoData(username, data);

            // Invalidar cache después de eliminar
            const cacheKey = this._cacheService.generateCacheKey('todos', username, 'list');
            await this._cacheService.invalidateCache(cacheKey);

            this._logOperation(OPERATION_DELETE, username, id);

            res.status(204).send();
        } catch (error) {
            console.error('[TodoController] Error in delete:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    _logOperation (opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            this._redisClient.publish(this._logChannel, JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            }))
        })
    }

    _getTodoData (userID) {
        var data = cache.get(userID)
        if (data == null) {
            data = {
                items: {
                    '1': {
                        id: 1,
                        content: "Create new todo",
                    },
                    '2': {
                        id: 2,
                        content: "Update me",
                    },
                    '3': {
                        id: 3,
                        content: "Delete example ones",
                    }
                },
                lastInsertedID: 3
            }

            this._setTodoData(userID, data)
        }
        return data
    }

    _setTodoData (userID, data) {
        cache.put(userID, data)
    }
}

module.exports = TodoController