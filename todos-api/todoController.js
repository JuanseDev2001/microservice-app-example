'use strict';
const cache = require('memory-cache');
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const CircuitBreaker = require('opossum');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';


class TodoController {
    constructor({tracer, redisClient, logChannel}) {
        this._tracer = tracer;
        this._redisClient = redisClient;
        this._logChannel = logChannel;

        // Circuit breaker para publicar en Redis
        this._redisBreaker = new CircuitBreaker(
            (message) => {
                return new Promise((resolve, reject) => {
                    this._redisClient.publish(this._logChannel, message, (err, reply) => {
                        if (err) return reject(err);
                        resolve(reply);
                    });
                });
            },
            {
                timeout: 2000, 
                errorThresholdPercentage: 10, 
                resetTimeout: 10000, 
                volumeThreshold: 3 
            }
        );
        
        this._redisBreaker.fallback(() => {
            // Fallback si Redis no responde
            return 'Redis no disponible';
        });
    }

    // TODO: these methods are not concurrent-safe
    list (req, res) {
        const data = this._getTodoData(req.user.username)

        res.json(data.items)
    }

    create (req, res) {
        // TODO: must be transactional and protected for concurrent access, but
        // the purpose of the whole example app it's enough
        const data = this._getTodoData(req.user.username)
        const todo = {
            content: req.body.content,
            id: data.lastInsertedID
        }
        data.items[data.lastInsertedID] = todo

        data.lastInsertedID++
        this._setTodoData(req.user.username, data)

        this._logOperation(OPERATION_CREATE, req.user.username, todo.id)

        res.json(todo)
    }

    delete (req, res) {
        const data = this._getTodoData(req.user.username)
        const id = req.params.taskId
        delete data.items[id]
        this._setTodoData(req.user.username, data)

        this._logOperation(OPERATION_DELETE, req.user.username, id)

        res.status(204)
        res.send()
    }

    _logOperation (opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            const message = JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            });
            this._redisBreaker.fire(message)
                .catch(err => {
                    // Loguea el error si el breaker está abierto o Redis falla
                    console.error('Circuit breaker: Redis publish failed', err);
                });
        });
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