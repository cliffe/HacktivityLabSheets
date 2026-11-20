---
title: "Fooling a Machine Learning Model"
author: ["Thomas Shaw"]
license: "CC BY-SA 4.0"
description: "Learn how a machine learning model makes its decisions, then make a deployed digit reader give wrong answers: first with ordinary rotations and shifts, then with the fast gradient sign method, and finally with projected gradient descent to force the answer you choose."
overview: |
  A model can perform very well on test data and still be fooled by inputs chosen for that purpose. This lab assumes no previous knowledge of machine learning. You will start by finding out what a model is, how images are stored as numbers, and how a model decides on its answer, working through each idea with small examples of your own.

  You will then carry out evasion attacks against a company's deployed digit reader. You will begin with changes a person would barely notice, then use the model's own gradients to craft an adversarial example, and finally force the model to give the exact wrong answer you pick. This is a Hackerbot lab. Hackerbot will test your altered images and reward you with flags.
tags: ["machine-learning", "ai-security", "evasion", "adversarial-examples", "fgsm", "pgd", "numpy", "tensorflow", "hackerbot"]
categories: ["ai_security"]
type: ["hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SPAI"
    topic: "Attacks on machine learning models"
    keywords: ["evasion attacks", "adversarial examples"]
---

## Introduction {#introduction}

Machine learning is now used to make decisions in many systems that matter for security: filtering spam and phishing emails, spotting malware, unlocking phones with a face, and reading road signs in cars. These systems are not programmed with rules in the usual way. They learn their behaviour from examples, and what they learn can be surprisingly fragile. A model that is right almost every time on ordinary inputs can often be made to give a wrong answer by an input that has been changed very slightly, in just the right way.

This lab doesn't assume that you know anything about machine learning. The first part introduces the ideas you need, one at a time, and you will try each of them out yourself. You will then use those ideas to attack a deployed model, without changing the model at all: you will only change what you show it.

In this lab you will:

* find out what a machine learning model is, and how it decides on an answer
* see how an image is stored as numbers, and change it with Python and NumPy
* fool a model using only ordinary rotations and shifts
* learn what a gradient is, and what it tells an attacker
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

### Working in a Jupyter notebook {#working-in-a-jupyter-notebook}

You will write and run Python in a **Jupyter notebook**. A notebook is a document made up of **cells**. Some cells contain explanations, and others contain code that you can run, one cell at a time, with the output appearing directly underneath. This makes notebooks popular for machine learning, as you can try something, look at the result, and try again, without starting a program from the beginning each time.

\==action: Double-click the JupyterLab icon on the desktop.== A terminal window opens and starts the notebook server, and your browser then opens JupyterLab. Leave the terminal window open while you work.

\==action: In JupyterLab, open `evasion.ipynb`.== You will work through this notebook as you follow this sheet.

A few things are useful to know before you start:

* To run a cell, click on it and press Shift and Enter together. A number appears beside the cell when it has finished, such as `[3]`, and a `[*]` means that it is still running.
* Variables are kept between cells. If one cell sets `image`, every cell you run afterwards can use `image`. This is why the cells need to be run in order, from the top.
* You can add your own cells to try things out. ==action: Click on a cell, then click the **+** button in the notebook's toolbar== to add an empty cell below it. Throughout this lab, a cell you add yourself is called a **scratch cell**.
* If things get confused (for example, after running cells out of order), use **Kernel → Restart Kernel**, then run the cells again from the top.

> Tip: When this sheet shows some Python code, type it into a scratch cell and run it. Typing it yourself, rather than only reading it, is the quickest way to learn what it does.

{% include hackerbot-intro.md role="check the images you create" chat="hello" %}

## What is machine learning? {#what-is-machine-learning}

Imagine that you are asked to write a program that decides whether an email is spam. The traditional approach is to write the rules yourself: if the subject contains "you have won", or the sender is on a block list, then mark it as spam. This works for a while, but spammers soon change their wording, and you can't possibly think of every rule.

Machine learning takes a different approach. Instead of writing the rules, you collect a large number of emails that people have already marked as spam or not spam, and give them to a learning algorithm. The algorithm works out for itself which patterns tell the two kinds apart, and the result is called a **model**. You can then give the model a new email that it has never seen, and it will make a **prediction**: spam, or not spam.

A few terms come up again and again:

* An **example** is one item of data, such as one email or one image.
* A **label** is the correct answer for an example, such as "spam" or "the digit 7".
* **Training** is the process of a model learning from labelled examples.
* A **prediction** is the answer a trained model gives for an example.
* A **class** is one of the possible answers. A spam filter has two classes, and the model in this lab has ten (the digits 0 to 9). Choosing between a fixed set of classes is called **classification**.

The model you will attack in this lab reads handwritten digits. It was trained on MNIST, a well-known dataset of 70,000 small pictures of handwritten digits, each labelled with the digit it shows (LeCun et al., 1998).

A model has no understanding of the task. It doesn't know what a 7 looks like in the way that you do; it only learnt patterns of numbers that tended to go with the label 7 in its training data. Those patterns usually work well, but they are not the same as the features a person relies on, and this is the gap that an attacker uses.

## Images are numbers {#images-are-numbers}

A computer stores an image as a grid of numbers. Each MNIST image is 28 pixels wide and 28 pixels high, and each pixel is a single number describing how bright it is. In this lab, pixel values run from 0 to 1: 0 is black, 1 is white, and the numbers in between are shades of grey. The digits are written in white on a black background.

> Note: Images are often stored with pixel values from 0 to 255 instead, and dividing by 255 turns these into values from 0 to 1. Models generally work better with small numbers, so this is a common first step.

So, as far as the model is concerned, every image is simply a grid of 784 numbers (28 × 28), and nothing else.

### How the model gives its answer {#how-the-model-gives-its-answer}

When the model is given an image, it doesn't simply give one answer. It gives 10 numbers, one for each class. Each of these is a **probability**: how likely the model thinks it is that the image shows that digit, from 0 (certainly not) to 1 (certainly). The 10 numbers always add up to 1. For example, the model's output for an image of a 7 might look like this:

```
digit:        0     1     2     3     4     5     6     7     8     9
probability:  0.00  0.01  0.02  0.00  0.00  0.00  0.00  0.95  0.00  0.02
```

The **prediction** is the class with the highest probability, here 7, and that highest probability (0.95) is often called the model's **confidence**. To fool the model, an attacker needs to change the image so that some other class ends up with the highest probability.

## Talking to the model {#talking-to-the-model}

The company has deployed its model as a web service, at `http://hackerbot:5000`. You don't have a copy of the model; you send it an image, and it sends back its answer. A service that programs use to talk to each other like this is called an **API** (application programming interface), and it is how many organisations make their models available.

\==action: Read the code in section 1 of the notebook, then run it.== It loads the Python libraries the lab uses, and defines a few small functions (helpers) that talk to the API for you:

* `get_challenge(name)` fetches one of your challenges from the API. A challenge contains an image, and the rules for that attack.
* `ask_model(image)` sends an image to the model, and gives back two things: the digit the model chose, and all 10 of its probabilities.
* `show(image, title)` draws an image, with a title above it.

\==action: Run the first cell in section 2 of the notebook.== It fetches your first challenge image, asks the model what it is, and shows the image with the model's answer. Your image is different from those of other students.

### Looking at the image and the answer {#looking-at-the-image-and-the-answer}

The variable `image` now holds your challenge image, as a NumPy array. NumPy is the Python library that almost all machine learning code uses to store and work with large amounts of numbers. ==action: Add a scratch cell below this cell, and run:==

```python
print(image.shape)
print(image.min(), image.max())
```

The **shape** `(28, 28)` tells you that the image has 28 rows of 28 pixels, and the smallest and largest values show that the pixels run from 0 to 1.

You can pick out part of an image using square brackets, with the row first and then the column, both counted from 0, starting from the top-left corner. `10:14` means "from 10, up to (but not including) 14", so this prints a 4 by 4 square of pixels from near the middle of the image, rounded to 2 decimal places:

```python
print(np.round(image[10:14, 10:14], 2))
```

Now look at the model's full answer for the image:

```python
prediction, probabilities = ask_model(image)
print(prediction)
print(np.round(probabilities, 3))
print(probabilities.max())
```

`ask_model` gives back two values, so two variable names are given on the left of the `=`, separated by a comma. The first holds the prediction, and the second holds the 10 probabilities. `.max()` finds the highest of them, which is the model's confidence.

> Question: Which digit does the model think your image shows, and how confident is it? Which digit has the second highest probability?

### Changing an image {#changing-an-image}

Because an image is just numbers, you can change it with arithmetic. Adding 0.3 to an array adds 0.3 to every pixel, which makes the whole image brighter:

```python
brighter = image + 0.3
print(brighter.max())
```

Some pixels are now above 1, which isn't a valid brightness. `np.clip` fixes this, by raising any value below a lower limit up to that limit, and lowering any value above an upper limit down to it. On a small example:

```python
print(np.clip(np.array([-0.2, 0.5, 1.3]), 0, 1))
```

This prints `[0.  0.5 1. ]`. So, to brighten the image properly, and see what the model makes of the result:

```python
brighter = np.clip(image + 0.3, 0, 1)
prediction, _ = ask_model(brighter)
show(brighter, f"Model reads: {prediction}")
```

The `_` is a name for a value that you don't need: here, the probabilities.

> Question: Did brightening the image change the model's answer? Did it change its confidence? (Use `ask_model` again, keeping the probabilities, to find out.)

## What is an adversarial example? {#what-is-an-adversarial-example}

Szegedy et al. (2014) made a surprising discovery about models that classify images. They found that they could take an image that a model classified correctly, change it so slightly that a person could see no difference, and the model would then give a completely different answer, often with high confidence. An input that has been altered in this way, so that a model gets it wrong, is called an **adversarial example**, and the change made to it is called a **perturbation**.

Goodfellow et al. (2015) gave a well-known example: a picture of a panda, which a model recognised as a panda, and the same picture with a faint pattern of noise added, which the model recognised as a gibbon with 99% confidence. To a person, the two pictures looked the same.

Adversarial examples work in the physical world too. Eykholt et al. (2018) placed a few black and white stickers on a real stop sign, in a pattern chosen to fool a road sign classifier. To a person, it looked like a stop sign with some graffiti, but the classifier read it as a speed limit sign, from a range of distances and angles.

Using adversarial examples against a model that is already trained and deployed is called an **evasion attack**, because the attacker evades the model's correct decision. Think of malware altered so that a detector classes it as safe, or spam reworded so that a filter delivers it. An evasion attack doesn't need any access to the model's training, only the ability to choose what is shown to it.

Why should this be possible at all? A useful way to picture a classifier is as a map. Every possible image is a point on the map, and the model divides the map into ten regions, one for each digit. The lines between the regions are called **decision boundaries**. The training images lie well inside the right regions, but the model was never shown most of the map, and the boundaries can lie surprisingly close to ordinary images in some directions. An attacker's job is to find a short path, from where the image is, across the nearest boundary.

An attack that simply makes the model wrong is called **untargeted**. An attack that makes it give one particular wrong answer, chosen by the attacker, is called **targeted**. You will do both in this lab.

## Fooling a model with ordinary changes {#fooling-a-model-with-ordinary-changes}

The first attack needs no knowledge of how the model works. Every photograph is taken from a slightly different angle, and every digit is written a little differently, so a slightly tilted or off-centre digit is still a perfectly normal input. Pierazzi et al. (2020) describe this as working in the **problem space**: the changes are ones that could occur in the real world, rather than arbitrary changes to pixel values.

The second cell in section 2 of the notebook defines a function, `transform`, that turns an image by an **angle** (in degrees) and then moves it by a **shift** (in pixels). A positive `shift_x` moves the digit to the right, and a positive `shift_y` moves it down; negative values move it the other way. Positive and negative angles turn it in opposite directions.

The challenge gives you limits for each: how many degrees you may turn the image either way, and how many pixels you may move it in each direction. Your task is to find a combination, within those limits, that the model misreads.

### Trying many values with a loop {#trying-many-values-with-a-loop}

You could try values by hand, one at a time, but a **loop** can try them for you. `range(start, stop, step)` gives you numbers from `start`, going up by `step` each time, and stopping *before* `stop`:

```python
print(list(range(-10, 11, 5)))
```

This prints `[-10, -5, 0, 5, 10]`. A `for` loop runs the indented lines below it once for each of those numbers. This loop tries a number of brightness changes on your image, and prints what the model makes of each one:

```python
for amount in [-0.3, -0.1, 0.1, 0.3]:
    changed = np.clip(image + amount, 0, 1)
    prediction, _ = ask_model(changed)
    print(amount, prediction)
```

To try every combination of two settings, put one loop inside another. The inner loop runs completely, once for each value of the outer loop:

```python
for a in [1, 2]:
    for b in [10, 20]:
        print(a, b)
```

This prints `1 10`, `1 20`, `2 10` and `2 20`. With three settings, you would need three loops.

You can also make a loop print only the results you are interested in, using `if`. The challenge records the correct digit for your image as `challenge["true_label"]`, so `if prediction != challenge["true_label"]:` picks out the cases where the model got it wrong (`!=` means "is not equal to").

> Tip: Each call to `ask_model` takes a moment, so a loop over thousands of combinations is slow. Start with large steps between the values you try, and look more closely around any that come close.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

> Hackerbot: Find a rotation and a shift, within the limits, that make the model misread the digit.

\==action: Complete the second cell in section 2 of the notebook==, setting `angle`, `shift_x` and `shift_y` to a combination that works, and run it to check the result. When the model has misread the digit, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Question: Does the image the model got wrong still look like the same digit to you? What does this tell you about how the model's idea of the digit differs from yours?

## How a model learns, and what a gradient is {#how-a-model-learns}

The next two attacks use information from inside the model, so it helps to have a rough picture of how a model learns. You don't need to understand the mathematics.

The model in this lab is a **neural network**. It is made up of **layers**, each of which takes in some numbers, combines them, and passes new numbers on to the next layer, until the last layer gives out the 10 probabilities. How the layers combine their numbers is controlled by a large number of **weights**. When the model is first created, the weights are random, so its answers are no better than guesses. **Training** adjusts them, a little at a time:

1. The model makes predictions for some training examples.
2. These are compared with the labels, giving a number called the **loss**, which measures how wrong the model was. A confident correct answer gives a low loss, and a confident wrong answer gives a high loss.
3. Every weight is nudged slightly in whichever direction would make the loss a little lower.
4. This is repeated, many thousands of times, until the model's answers are good.

How does training know which way to nudge each weight? It calculates the **gradient**. Imagine standing on a hillside in thick fog, trying to reach the bottom of the valley. You can't see the valley, but you can feel which way the ground slopes under your feet, and take a step downhill. The gradient is that slope: for each weight, it says whether increasing the weight would make the loss go up or down, and how strongly. Training takes small steps downhill, again and again.

### Turning the gradient on the input {#turning-the-gradient-on-the-input}

Here is the key idea for an attacker. Exactly the same calculation can be done for the *pixels of an image*, instead of the weights. The result is a gradient with one value for each pixel, which answers the question: if this pixel were made a little brighter, would the model become more wrong or less wrong about this label, and how strongly?

* A positive value means that brightening that pixel would increase the loss (the model would become more wrong).
* A negative value means that brightening that pixel would decrease the loss, so *darkening* it would increase the loss.

Training walks downhill, to make the model less wrong. An attacker can walk *uphill* instead, changing the image's pixels to make the model more wrong, while leaving the model itself untouched.

The company's API will give you the gradient for any image and any label you choose. Many deployed models don't do this, but it lets you concentrate on the idea here. An attacker who can't get the gradients from a model may still be able to calculate them from a copy of the model, either one that is publicly available or one that they have stolen.

\==action: Read the code in the first cell of section 3, then run it.== It defines `get_gradient(image, label)`, fetches your next challenge (with its image, its correct label and its **epsilon**, explained below), and shows the gradient for the correct label as a picture.

The gradient looks like noise to a person, but every value in it is useful to an attacker. ==action: In a scratch cell, run:==

```python
print(gradient.shape)
print(gradient[12:16, 12:16])
```

The gradient is the same shape as the image, with one value for each pixel. The values are often very small, and NumPy may show them in scientific notation: `3.2e-05` means 3.2 × 10⁻⁵, or 0.000032. Their size doesn't matter here; what matters is their sign (whether each one is positive or negative), because that gives the direction to change each pixel. `np.sign` turns every negative number into -1, every positive number into 1, and leaves 0 as 0:

```python
print(np.sign(np.array([-0.003, 0.0, 0.02])))
```

This prints `[-1.  0.  1.]`.

## The fast gradient sign method {#the-fast-gradient-sign-method}

The **fast gradient sign method**, or FGSM (Goodfellow et al., 2015), makes a single change to the image. It takes the gradient for the image's correct label, keeps only its sign for each pixel, and moves every pixel by the same small amount in that direction: uphill, to make the model more wrong. The size of that amount is called **epsilon**.

Epsilon is the attacker's limit. No pixel may change by more than epsilon, which keeps the change small. With pixel values from 0 to 1, an epsilon of 0.2 lets each pixel get brighter or darker by up to a fifth of the full range. Written as a formula:

```
adversarial image = original image + epsilon × sign(gradient)
```

followed by clipping, so that every pixel stays between 0 and 1.

### Why the direction matters {#why-the-direction-matters}

You might wonder whether the gradient is needed at all. Would *any* change of the same size fool the model? You can test this, by changing every pixel of your challenge image by a random amount between -epsilon and +epsilon. ==action: In a scratch cell, run:==

```python
noise = np.random.uniform(-epsilon, epsilon, size=image.shape)
noisy = np.clip(image + noise, 0, 1)
prediction, probabilities = ask_model(noisy)
show(noisy, f"Model reads: {prediction}")
print(probabilities.max())
```

Run the cell a few times, as the noise is different each time. You will usually find that the model still reads the digit correctly, even though every pixel has changed by up to epsilon.

Random changes mostly cancel each other out: some push the model towards the wrong answer, and about as many push it back. The gradient tells you which way each pixel needs to move so that *all* of the changes push the same way, towards a wrong answer. That is why a carefully aimed perturbation of the same size can succeed where random noise fails.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

> Hackerbot: Use the fast gradient sign method to make the model misread your image, without changing any pixel by more than epsilon.

\==action: Complete the second cell in section 3 of the notebook== by calculating `adversarial`. The cell then shows your image with the model's answer, and the largest change you made to any pixel. When the model has misread the image, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Show your original and adversarial images, and the noisy image from your random test. Explain in your own words why the adversarial image fools the model when the random noise, of the same size, usually doesn't.

## Choosing the wrong answer {#choosing-the-wrong-answer}

FGSM only needs the model to be wrong, and any wrong answer will do. A more capable attacker chooses *which* wrong answer the model gives: a malware author wants their file classed as safe, not as some other kind of malware. This is a targeted attack.

**Projected gradient descent**, or PGD (Madry et al., 2018), can be pointed at a target class. It differs from FGSM in two ways.

**It walks towards the target.** Instead of the gradient for the correct label, PGD asks for the gradient for the **target** label. A low loss for the target label means the model is confident that the image shows the target. So, rather than walking uphill to make the model more wrong, PGD walks *downhill* on the target's loss, to make the model more right about the target. In other words, it steps in the opposite direction to the sign of the gradient.

**It takes many small steps.** One large step, as in FGSM, is a rough guess, since the slope of the hill changes as you move. PGD takes many small steps instead, and asks for a fresh gradient before each one, so that it can change course on the way.

Taking many steps raises a problem: if each step moves a pixel a little, after enough steps it could move a long way from where it started, breaking the epsilon limit. So, after every step, PGD **projects** the image back within the limits: it clips each pixel so that it is no more than epsilon away from that pixel's value in the original image, and then clips again so that it stays between 0 and 1.

### Keeping within a limit of the original {#keeping-within-a-limit-of-the-original}

`np.clip` can take arrays as its limits, as well as single numbers, so each value can have its own lower and upper limit. On a small example, this keeps each value of `changed` within 0.2 of the matching value in `original`:

```python
original = np.array([0.0, 0.5, 1.0])
changed = np.array([0.4, 0.1, 0.7])
print(np.clip(changed, original - 0.2, original + 0.2))
```

This prints `[0.2 0.3 0.8]`: each value has been pulled back to the nearest point within 0.2 of the original.

Here is the whole idea of repeated steps with a projection, using a single number rather than an image. The loop takes a step of 0.1 each time, but the number is never allowed to move more than 0.25 from where it started:

```python
start = 0.5
value = start
for step in range(5):
    value = value + 0.1
    value = np.clip(value, start - 0.25, start + 0.25)
    print(step, value)
```

The value rises to 0.6, then 0.7, and then stays at 0.75, the edge of its limit, however many more steps are taken. In PGD the same thing happens to each pixel, except that the direction of each step comes from the gradient.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Hackerbot: Use projected gradient descent to make the model read your image as the target class in your challenge.

\==action: Complete the loop in section 4 of the notebook.== The challenge gives you your target class and epsilon. When the model reads the image as your target, ==action: run the save cell, then say 'ready'== to Hackerbot.

> Hint: If the model moves further away from your target, rather than towards it, check which way your step goes.

Don't forget to ==action: save and submit any flags!==

> Question: Why might a targeted attack be more useful to a real attacker than one that simply makes the model wrong?

## Defending against evasion {#defending-against-evasion}

Evasion is difficult to defend against completely, and a number of proposed defences have later been broken. Some of the better-known approaches are:

* **Adversarial training** (Madry et al., 2018) adds adversarial examples, with their correct labels, to the training data, so that the model learns to handle them. It helps, but it costs more training time and can reduce accuracy on clean data.
* **Input preprocessing** applies changes such as smoothing to inputs before the model sees them, in the hope of removing the attacker's pattern.
* **Gradient masking** hides or distorts the gradients. It may look effective because simple attacks stop working, but a stronger attack designed for the defence frequently gets through. Athalye et al. (2018) showed this for a number of published defences.

> Log Book Question: An organisation proposes to protect its model by removing the gradient feature from its API. Explain why this alone wouldn't be enough. Think about your first attack in this lab, and about what an attacker could do with a copy of the model.

## Conclusion {#conclusion}

At this point you have:

* learnt what a machine learning model is, and how it decides on an answer
* explored an image stored as numbers, and changed it with NumPy
* fooled a model using only rotations and shifts
* explained what a gradient tells an attacker
* used FGSM to craft an adversarial example, and compared it with random noise
* used PGD to force the answer you chose
* considered why evasion is difficult to defend against

> Tip: Well done!

## Key terms {#key-terms}

| Term | Meaning |
|---|---|
| Example | One item of data, such as one image |
| Label | The correct answer for an example |
| Class | One of the possible answers a model can give |
| Model | The result of training: something that makes predictions for new examples |
| Probability | How likely the model thinks it is that an input belongs to a class, from 0 to 1 |
| Confidence | The highest of a model's probabilities for an input |
| API | A service that programs use to talk to each other; here, the way you send images to the model |
| Weights | The numbers inside a model that training adjusts |
| Loss | A measure of how wrong a model's predictions are; training tries to reduce it |
| Gradient | For each weight or pixel, which way a small change would move the loss, and how strongly |
| Adversarial example | An input altered so that a model gets it wrong |
| Perturbation | The change made to an input to create an adversarial example |
| Evasion attack | Using adversarial examples against a deployed model |
| Decision boundary | Where a model's answer changes from one class to another |
| Epsilon | The most that any pixel may change |
| Untargeted attack | An attack that makes a model give any wrong answer |
| Targeted attack | An attack that makes a model give a particular wrong answer, chosen by the attacker |
| FGSM | The fast gradient sign method: one step of size epsilon, in the direction of the sign of the gradient |
| PGD | Projected gradient descent: many small steps, each kept within epsilon of the original |

## References {#references}

Athalye, A., Carlini, N. and Wagner, D. (2018) 'Obfuscated Gradients Give a False Sense of Security', *International Conference on Machine Learning*.

Eykholt, K., Evtimov, I., Fernandes, E., Li, B., Rahmati, A., Xiao, C., Prakash, A., Kohno, T. and Song, D. (2018) 'Robust Physical-World Attacks on Deep Learning Visual Classification', *IEEE/CVF Conference on Computer Vision and Pattern Recognition*.

Goodfellow, I.J., Shlens, J. and Szegedy, C. (2015) 'Explaining and Harnessing Adversarial Examples', *International Conference on Learning Representations*.

LeCun, Y., Bottou, L., Bengio, Y. and Haffner, P. (1998) 'Gradient-Based Learning Applied to Document Recognition', *Proceedings of the IEEE*, 86(11), pp. 2278-2324.

Madry, A., Makelov, A., Schmidt, L., Tsipras, D. and Vladu, A. (2018) 'Towards Deep Learning Models Resistant to Adversarial Attacks', *International Conference on Learning Representations*.

Pierazzi, F., Pendlebury, F., Cortellazzi, J. and Cavallaro, L. (2020) 'Intriguing Properties of Adversarial ML Attacks in the Problem Space', *IEEE Symposium on Security and Privacy*.

Szegedy, C., Zaremba, W., Sutskever, I., Bruna, J., Erhan, D., Goodfellow, I. and Fergus, R. (2014) 'Intriguing Properties of Neural Networks', *International Conference on Learning Representations*.
