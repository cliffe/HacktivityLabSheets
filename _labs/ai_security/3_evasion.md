---
title: "Fooling a Machine Learning Model"
author: ["Thomas Shaw"]
license: "CC BY-SA 4.0"
description: "Make a deployed digit reader give wrong answers: first with ordinary rotations and shifts, then with the fast gradient sign method, and finally with projected gradient descent to force the answer you choose."
overview: |
  A model can perform very well on test data and still be fooled by inputs chosen for that purpose. In this lab you will carry out evasion attacks against a deployed digit reader. You will begin with changes a person would barely notice, then use the model's own gradients to craft an adversarial example, and finally force the model to give the exact wrong answer you pick.

  This is a Hackerbot lab. Hackerbot will test your altered images and reward you with flags.
tags: ["machine-learning", "ai-security", "evasion", "adversarial-examples", "fgsm", "pgd", "tensorflow", "hackerbot"]
categories: ["ai_security"]
type: ["hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SPAI"
    topic: "Attacks on machine learning models"
    keywords: ["evasion attacks", "adversarial examples"]
---

## Introduction {#introduction}

In the previous labs you copied a model and poisoned the data that a model learnt from. In this lab you won't change the model at all. You will change what you show it.

An **adversarial example** is an input that has been altered, often very slightly, so that a model gets it wrong. Goodfellow et al. (2015) showed that small, carefully chosen changes could make image classifiers fail with high confidence, even when a person would see no difference. Using such inputs against a deployed model is called an **evasion attack**, and it matters wherever a model is making a decision that an attacker would like to influence: a spam filter deciding whether to deliver a message, or a malware detector deciding whether to raise an alert.

The attack uses the fact that a model has learnt to draw boundaries between its classes, and that these boundaries can be close to ordinary inputs.

In this lab you will:

* fool a model using only ordinary rotations and shifts
* learn what a gradient tells an attacker
* use the fast gradient sign method to make a model misread an image
* use projected gradient descent to force the answer you choose

> Warning: Only attack systems you have permission to attack.

> Note: This lab is adapted from the [Security-of-AI](https://github.com/habroshan/Security-of-AI) project by Anglia Ruskin University, funded by CyBOK, and draws on the CyBOK Security and Privacy of AI Knowledge Guide. Contains public sector information licensed under the Open Government Licence v3.0.

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

\==VM: On the desktop VM==, log in using:

- User: `student`
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

The hackerbot_server runs both Hackerbot and the model you will attack. The VM needs to be running to complete the lab, but you can't log in to it.

\==action: Double-click the JupyterLab icon on the desktop.== A terminal window opens and starts the notebook server, and your browser then opens JupyterLab. Leave the terminal window open while you work.

\==action: In JupyterLab, open `evasion.ipynb`, and run the cell in section 1.==

> Tip: To run a notebook cell, click on it and press Shift and Enter together. Run the cells in order, from the top.

{% include hackerbot-intro.md role="check the images you create" chat="hello" %}

## Fooling a model with ordinary changes {#fooling-a-model-with-ordinary-changes}

The first attack needs no knowledge of how the model works. Every photograph is taken from a slightly different angle, and every digit is written a little differently. Pierazzi et al. (2020) describe this as working in the **problem space**: the changes are ones that could occur in the real world, rather than arbitrary changes to pixel values.

\==action: Run the first cell in section 2 of the notebook.== It fetches your challenge image from the API, and shows what the model thinks it is. Your image is different from those of other students.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

> Hackerbot: Find a rotation and a shift, within the limits, that make the model misread the digit.

\==action: Complete the next cell in the notebook.== Try different values of `angle`, `shift_x` and `shift_y`, and run the cell to see each result.

> Hint: Trying values by hand soon becomes slow. A loop inside a loop can try a range of values for you, and stop when `ask_model` gives a different answer from the true label in `challenge["true_label"]`.

When the model has misread the digit, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Question: Does the image the model got wrong still look like the same digit to you?

## What a gradient tells an attacker {#what-a-gradient-tells-an-attacker}

You trained a model in an earlier lab, so you have seen that the training process tries to reduce a number called the **loss**, which measures how wrong the model is. Training does this by working out how a small change to each weight would change the loss, then adjusting the weights in the helpful direction. That measure of "how would the loss change if I nudged this?" is called the **gradient**.

Exactly the same calculation can be done for the pixels of an input. The result has one value for each pixel, and it answers the question: if this pixel were a little brighter, would the model become more or less wrong? An attacker who can obtain this has been told precisely how to change an image to make it fail.

> Note: Many models don't expose their gradients through an API. This one does so that you can concentrate on the idea. An attacker with a stolen copy of a model, like the one you made in the first lab, can calculate gradients for themselves.

## The fast gradient sign method {#the-fast-gradient-sign-method}

The fast gradient sign method, or FGSM (Goodfellow et al., 2015), makes one change to the image. It takes the gradient, keeps only its direction (positive or negative) for each pixel, and moves every pixel a small amount in that direction. The amount is called **epsilon**, and limiting it is what keeps the change small.

Written as a formula, with pixel values between 0 and 1:

```
adversarial image = original image + epsilon * sign(gradient)
```

\==action: Run the first cell in section 3 of the notebook.== It fetches your next challenge, and displays the gradient as an image.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

> Hackerbot: Use the fast gradient sign method to make the model misread your image, without changing any pixel by more than epsilon.

\==action: Complete the next cell in the notebook== to calculate `adversarial`. Remember to clip the result, so that the pixel values stay between 0 and 1.

When the model has misread the image, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Show your original and adversarial images. Explain in your own words why adding such a faint pattern can change the model's answer.

## Choosing the wrong answer {#choosing-the-wrong-answer}

FGSM only needs the model to be wrong, and it takes one large step. Projected gradient descent, or PGD (Madry et al., 2018), takes many small steps, and it can be pointed at a target: a specific wrong answer.

To do this, ask for the gradient of the loss for the **target** label. A low loss for that label means the model is confident of it, so you step in the *opposite* direction to the gradient to reduce the loss. Each time, you then "project" the image back, by clipping it so that it stays within epsilon of the original.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Hackerbot: Use projected gradient descent to make the model read your image as the target class in your challenge.

\==action: Complete the loop in section 4 of the notebook.== Each pass needs three lines: one to take a step, and two to clip.

> Hint: Check the sign of your step. For a targeted attack, you subtract `step_size * np.sign(gradient)`, as you want the loss for the target to fall.

> Hint: To keep an image within epsilon of the original, use `np.clip(adversarial, image - epsilon, image + epsilon)`.

When the model reads the image as your target, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Question: Why might a targeted attack be more useful to a real attacker than one that simply makes the model wrong?

## Defending against evasion {#defending-against-evasion}

Evasion is difficult to defend against completely, and a number of proposed defences have later been broken. Some of the better-known approaches are:

* **Adversarial training** (Madry et al., 2018) adds adversarial examples to the training data, so that the model learns to handle them. It helps, but it costs more training time and can reduce accuracy on clean data.
* **Input preprocessing** applies changes such as smoothing to inputs, in the hope of removing the attacker's pattern.
* **Gradient masking** hides or distorts the gradients. It may look effective because simple attacks stop working, but a stronger attack designed for the defence frequently gets through. Athalye et al. (2018) showed this for a number of published defences.

> Log Book Question: An organisation proposes to protect its model by hiding its gradients from the API. Considering all three labs in this series, explain why this alone wouldn't be enough.

## Conclusion {#conclusion}

At this point you have:

* fooled a model using only rotations and shifts
* explained what a gradient tells an attacker
* used FGSM to craft an adversarial example
* used PGD to force the answer you chose
* considered why evasion is difficult to defend against

> Tip: Well done!

Across these labs you have copied a model, poisoned its training and fooled it in use. A defender needs to consider each of those stages.

## References {#references}

Athalye, A., Carlini, N. and Wagner, D. (2018) 'Obfuscated Gradients Give a False Sense of Security', *International Conference on Machine Learning*.

Goodfellow, I.J., Shlens, J. and Szegedy, C. (2015) 'Explaining and Harnessing Adversarial Examples', *International Conference on Learning Representations*.

Madry, A., Makelov, A., Schmidt, L., Tsipras, D. and Vladu, A. (2018) 'Towards Deep Learning Models Resistant to Adversarial Attacks', *International Conference on Learning Representations*.

Pierazzi, F., Pendlebury, F., Cortellazzi, J. and Cavallaro, L. (2020) 'Intriguing Properties of Adversarial ML Attacks in the Problem Space', *IEEE Symposium on Security and Privacy*.
