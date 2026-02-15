package com.example.aura_app.alarm

import kotlin.random.Random

object MathDismissHelper {
    data class MathProblem(val question: String, val answer: Int)

    fun generate(difficulty: Int): MathProblem {
        return when (difficulty) {
            1 -> generateEasy()
            2 -> generateMedium()
            else -> generateHard()
        }
    }

    private fun generateEasy(): MathProblem {
        val a = Random.nextInt(1, 11)
        val b = Random.nextInt(1, 11)
        return if (Random.nextBoolean()) {
            MathProblem("$a + $b = ?", a + b)
        } else {
            val max = maxOf(a, b)
            val min = minOf(a, b)
            MathProblem("$max - $min = ?", max - min)
        }
    }

    private fun generateMedium(): MathProblem {
        val a = Random.nextInt(10, 30)
        val b = Random.nextInt(5, 15)
        val op = Random.nextInt(3)
        return when (op) {
            0 -> MathProblem("$a + $b = ?", a + b)
            1 -> MathProblem("$a - $b = ?", a - b)
            else -> {
                val x = Random.nextInt(2, 10)
                val y = Random.nextInt(2, 10)
                MathProblem("$x × $y = ?", x * y)
            }
        }
    }

    private fun generateHard(): MathProblem {
        val a = Random.nextInt(20, 60)
        val b = Random.nextInt(10, 30)
        val op = Random.nextInt(3)
        return when (op) {
            0 -> MathProblem("$a + $b = ?", a + b)
            1 -> MathProblem("$a - $b = ?", a - b)
            else -> {
                val x = Random.nextInt(5, 15)
                val y = Random.nextInt(5, 15)
                MathProblem("$x × $y = ?", x * y)
            }
        }
    }
}
