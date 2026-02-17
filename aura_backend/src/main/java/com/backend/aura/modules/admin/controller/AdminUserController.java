package com.backend.aura.modules.admin.controller;

import com.backend.aura.modules.common.dto.ApiResponse;
import com.backend.aura.modules.user.dto.response.UserResponse;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private static final Logger log = LoggerFactory.getLogger(AdminUserController.class);

    private final UserRepository userRepository;
    private final UserService userService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<UserResponse>>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "") String search) {

        log.debug("ADMIN_USER_CTRL - GET /api/admin/users | page: {} | size: {} | search: '{}'", page, size, search);

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<User> usersPage;
        if (search != null && !search.trim().isEmpty()) {
            String term = search.trim();
            usersPage = userRepository
                    .findByNameContainingIgnoreCaseOrEmailContainingIgnoreCaseOrUsernameContainingIgnoreCase(
                            term, term, term, pageable);
        } else {
            usersPage = userRepository.findAll(pageable);
        }

        Page<UserResponse> responsePage = usersPage.map(userService::mapToUserResponse);

        log.debug("ADMIN_USER_CTRL - GET /api/admin/users RESPONSE: {} users | totalPages: {} | totalElements: {}",
                responsePage.getNumberOfElements(), responsePage.getTotalPages(), responsePage.getTotalElements());

        return ResponseEntity.ok(ApiResponse.success(responsePage));
    }

    @GetMapping("/{uid}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable String uid) {
        log.debug("ADMIN_USER_CTRL - GET /api/admin/users/{}", uid);

        UserResponse user = userService.getUserDtoByUid(uid);
        if (user == null) {
            log.debug("ADMIN_USER_CTRL - GET /api/admin/users/{} RESPONSE: 404 Not Found", uid);
            return ResponseEntity.notFound().build();
        }

        log.debug("ADMIN_USER_CTRL - GET /api/admin/users/{} RESPONSE: 200 OK | username: {}", uid, user.getUsername());
        return ResponseEntity.ok(ApiResponse.success(user));
    }
}
