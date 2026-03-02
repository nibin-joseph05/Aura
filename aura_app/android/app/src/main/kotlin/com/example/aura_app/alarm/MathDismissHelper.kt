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
        val a = Random.nextInt(10, 50)
        val b = Random.nextInt(5, 30)
        return if (Random.nextBoolean()) {
            MathProblem("$a + $b = ?", a + b)
        } else {
            val max = maxOf(a, b)
            val min = minOf(a, b)
            MathProblem("$max - $min = ?", max - min)
        }
    }

    private fun generateMedium(): MathProblem {
        val op = Random.nextInt(4)
        return when (op) {
            0 -> {
                val a = Random.nextInt(30, 100)
                val b = Random.nextInt(15, 60)
                MathProblem("$a + $b = ?", a + b)
            }
            1 -> {
                val a = Random.nextInt(40, 120)
                val b = Random.nextInt(10, 50)
                MathProblem("$a - $b = ?", a - b)
            }
            2 -> {
                val x = Random.nextInt(6, 15)
                val y = Random.nextInt(6, 15)
                MathProblem("$x × $y = ?", x * y)
            }
            else -> {
                val divisors = listOf(2, 3, 4, 5, 6, 7, 8, 9)
                val d = divisors.random()
                val result = Random.nextInt(5, 15)
                val a = d * result
                MathProblem("$a ÷ $d = ?", result)
            }
        }
    }

    private fun generateHard(): MathProblem {
        val op = Random.nextInt(4)
        return when (op) {
            0 -> {
                val x = Random.nextInt(8, 20)
                val y = Random.nextInt(8, 20)
                MathProblem("$x × $y = ?", x * y)
            }
            1 -> {
                val a = Random.nextInt(3, 10)
                val b = Random.nextInt(3, 10)
                val c = Random.nextInt(1, 30)
                MathProblem("$a × $b + $c = ?", a * b + c)
            }
            2 -> {
                val a = Random.nextInt(3, 10)
                val b = Random.nextInt(3, 10)
                val c = Random.nextInt(1, 20)
                MathProblem("$a × $b - $c = ?", a * b - c)
            }
            else -> {
                val p = Random.nextInt(3, 10)
                val q = Random.nextInt(2, 8)
                val r = Random.nextInt(2, 10)
                val s = Random.nextInt(2, 8)
                MathProblem("$p × $q + $r × $s = ?", p * q + r * s)
            }
        }
    }
}
