---
name: Infrastructure Change Request
about: Template for infrastructure changes following GitOps workflow
title: '[INFRA] '
labels: infrastructure, gitops
assignees: ''

---

## 📋 Infrastructure Change Summary

**Target Environment:** 
- [ ] Staging (`env/staging`)
- [ ] Production (`env/production`)

**Type of Change:**
- [ ] Configuration update
- [ ] Resource scaling
- [ ] New service deployment
- [ ] Security update
- [ ] Cache configuration change
- [ ] Environment variable update

## 🎯 Objective

**What is the goal of this infrastructure change?**


**Why is this change necessary?**


## 🔧 Technical Details

### Services Affected:
- [ ] Redis
- [ ] Users API
- [ ] Auth API
- [ ] Todos API
- [ ] Log Message Processor
- [ ] Frontend

### Configuration Changes:
```yaml
# Paste relevant configuration changes here
```

### Resource Changes:
- **CPU**: Before → After
- **Memory**: Before → After
- **Replicas**: Before → After

## 🧪 Testing Plan

### Pre-deployment Testing:
- [ ] Configuration syntax validation
- [ ] Security scan passed
- [ ] Resource limits verified
- [ ] Dependencies checked

### Post-deployment Testing:
- [ ] Health checks pass
- [ ] Cache-Aside pattern working
- [ ] Performance meets baseline
- [ ] Integration tests pass

### Rollback Plan:
- [ ] Backup created
- [ ] Rollback procedure documented
- [ ] Rollback tested in staging (if applicable)

## 🔍 Impact Assessment

### Downtime Expected:
- [ ] Zero downtime (rolling update)
- [ ] Brief downtime (< 5 minutes)
- [ ] Extended downtime (> 5 minutes) - **Requires additional approvals**

### Cache Impact:
- [ ] Cache invalidation required
- [ ] Cache configuration changes
- [ ] No cache impact

### User Impact:
- [ ] No user impact
- [ ] Improved performance
- [ ] Temporary service degradation
- [ ] Feature changes

## 📊 Monitoring & Observability

### Metrics to Monitor:
- [ ] Cache hit/miss ratio
- [ ] Response times
- [ ] Error rates
- [ ] Resource utilization
- [ ] Service availability

### Alert Thresholds:
- Error rate > ____%
- Response time > ___ms
- CPU usage > ____%
- Memory usage > ____%

## 🔐 Security Considerations

- [ ] No hardcoded secrets
- [ ] Environment variables properly externalized
- [ ] Resource limits configured
- [ ] Network security maintained
- [ ] Compliance requirements met

## ✅ Pre-merge Checklist

### Code Review:
- [ ] Configuration reviewed by infrastructure team
- [ ] Security implications assessed
- [ ] Performance impact evaluated
- [ ] Documentation updated

### GitOps Workflow:
- [ ] Staging deployment successful (if targeting production)
- [ ] All automated tests passed
- [ ] Manual validation completed
- [ ] Stakeholder approval obtained (for production)

### Documentation:
- [ ] README updated (if necessary)
- [ ] Deployment runbook updated
- [ ] Monitoring documentation updated
- [ ] Rollback procedures documented

## 🔗 Related Issues/PRs

**Related Application PRs:**
- Link to related development changes

**Dependency PRs:**
- Link to prerequisite infrastructure changes

**Monitoring Setup:**
- Link to monitoring/alerting configuration

## 📝 Additional Notes

**Special Considerations:**


**Communication Plan:**
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled (if applicable)
- [ ] Status page updated (if applicable)

---

## 📋 Review Checklist for Approvers

- [ ] **Technical Review**: Configuration is correct and follows best practices
- [ ] **Security Review**: No security vulnerabilities introduced
- [ ] **Performance Review**: Resource allocation is appropriate
- [ ] **Process Review**: GitOps workflow followed correctly
- [ ] **Documentation Review**: All documentation is updated and accurate

**For Production Deployments Only:**
- [ ] **Staging Validation**: Successfully deployed and tested in staging
- [ ] **Business Approval**: Business stakeholders have approved the change
- [ ] **Timing Approval**: Deployment timing is appropriate
- [ ] **Rollback Plan**: Rollback plan is tested and ready