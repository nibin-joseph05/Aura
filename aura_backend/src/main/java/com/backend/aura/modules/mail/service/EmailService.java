package com.backend.aura.modules.mail.service;

import com.backend.aura.modules.mail.dto.EmailRequest;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Value("${app.name:Aura}")
    private String appName;

    @Value("${app.logo-url:}")
    private String logoUrl;

    public EmailService(JavaMailSender mailSender, TemplateEngine templateEngine) {
        this.mailSender = mailSender;
        this.templateEngine = templateEngine;
    }

    @Async
    public void sendWelcomeEmail(String toEmail, String userName) {
        Context context = new Context();
        context.setVariable("userName", userName);
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);

        String htmlContent = templateEngine.process("welcome-email", context);

        sendHtmlEmail(toEmail, "Welcome to Aura - Your Journey Begins!", htmlContent);
    }

    @Async
    public void sendProfileIncompleteReminder(String toEmail, String userName) {
        Context context = new Context();
        context.setVariable("userName", userName != null ? userName : "there");
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);

        String htmlContent = templateEngine.process("profile-incomplete-email", context);

        sendHtmlEmail(toEmail, "Complete Your Aura Profile", htmlContent);
    }

    @Async
    public void sendEmail(EmailRequest request) {
        Context context = new Context();
        context.setVariables(request.getVariables());
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);

        String htmlContent = templateEngine.process(request.getTemplateName(), context);

        sendHtmlEmail(request.getToEmail(), request.getSubject(), htmlContent);
    }

    private void sendHtmlEmail(String toEmail, String subject, String htmlContent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send email: " + e.getMessage());
        }
    }
}
