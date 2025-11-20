package com.backend.aura.controllers.user;

import com.backend.aura.models.user.User;
import com.backend.aura.services.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

//    @PostMapping("/create")
//    public User createUser(@RequestBody User user) {
//        return userService.createUser(user);
//    }
//
//    @GetMapping("/{uid}")
//    public User getUser(@PathVariable String uid) {
//        return userService.getUserById(uid);
//    }
//
//    @PutMapping("/update")
//    public User updateUser(@RequestBody User user) {
//        return userService.updateUser(user);
//    }
}
