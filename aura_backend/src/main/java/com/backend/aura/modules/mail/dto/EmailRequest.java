package com.backend.aura.modules.mail.dto;

import java.util.HashMap;
import java.util.Map;

public class EmailRequest {

    private String toEmail;
    private String subject;
    private String templateName;
    private Map<String, Object> variables;

    public EmailRequest() {
        this.variables = new HashMap<>();
    }

    public EmailRequest(String toEmail, String subject, String templateName) {
        this.toEmail = toEmail;
        this.subject = subject;
        this.templateName = templateName;
        this.variables = new HashMap<>();
    }

    public String getToEmail() {
        return toEmail;
    }

    public void setToEmail(String toEmail) {
        this.toEmail = toEmail;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public Map<String, Object> getVariables() {
        return variables;
    }

    public void setVariables(Map<String, Object> variables) {
        this.variables = variables;
    }

    public void addVariable(String key, Object value) {
        this.variables.put(key, value);
    }
}
