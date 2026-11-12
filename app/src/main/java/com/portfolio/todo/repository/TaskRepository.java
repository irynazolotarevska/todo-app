package com.portfolio.todo.repository;

import com.portfolio.todo.model.Task;
import com.portfolio.todo.model.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByStatus(TaskStatus status);
}
