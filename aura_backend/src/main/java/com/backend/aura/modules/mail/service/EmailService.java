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

    @Async
    public void sendSosAlertToAdmin(String adminEmail, String userName, String location, String triggeredAt) {
        Context context = new Context();
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("userName", userName);
        context.setVariable("location", location);
        context.setVariable("triggeredAt", triggeredAt);

        String htmlContent = templateEngine.process("sos-alert-admin", context);

        sendHtmlEmail(adminEmail, "🚨 URGENT: SOS Alert Triggered - " + userName, htmlContent);
    }

    @Async
    public void sendSosAlertToContact(String contactEmail, String contactName, String userName, String location,
            String triggeredAt) {
        Context context = new Context();
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("contactName", contactName);
        context.setVariable("userName", userName);
        context.setVariable("location", location);
        context.setVariable("triggeredAt", triggeredAt);

        String htmlContent = templateEngine.process("sos-alert-contact", context);

        sendHtmlEmail(contactEmail, "🚨 EMERGENCY: " + userName + " needs help!", htmlContent);
    }

    @Async
    public void sendWellnessApproved(String userEmail, String userName, String postTitle) {
        Context context = new Context();
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("userName", userName);
        context.setVariable("postTitle", postTitle);

        String htmlContent = templateEngine.process("wellness-approved", context);

        sendHtmlEmail(userEmail, "Your wellness post has been approved!", htmlContent);
    }

    @Async
    public void sendWellnessRejected(String userEmail, String userName, String postTitle, String reason) {
        Context context = new Context();
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("userName", userName);
        context.setVariable("postTitle", postTitle);
        context.setVariable("reason", reason);

        String htmlContent = templateEngine.process("wellness-rejected", context);

        sendHtmlEmail(userEmail, "Update on your wellness post", htmlContent);
    }

    @Async
    public void sendOtpVerification(String email, String otp, String purpose) {
        Context context = new Context();
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("otp", otp);
        context.setVariable("purpose", purpose);

        String htmlContent = templateEngine.process("otp-verification", context);

        sendHtmlEmail(email, "Your Aura Verification Code: " + otp, htmlContent);
    }

    @Async
    public void sendProfileUpdateNotification(String toEmail, String userName,
            java.util.Map<String, String> changedFields, String updatedAt) {
        Context context = new Context();
        context.setVariable("userName", userName);
        context.setVariable("appName", appName);
        context.setVariable("logoUrl", logoUrl);
        context.setVariable("changedFields", changedFields.entrySet());
        context.setVariable("updatedAt", updatedAt);

        String htmlContent = templateEngine.process("profile-updated-email", context);

        sendHtmlEmail(toEmail, "Your Aura Profile Was Updated", htmlContent);
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
