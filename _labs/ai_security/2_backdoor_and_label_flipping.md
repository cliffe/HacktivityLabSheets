---
title: "Poisoning Data and Planting Backdoors"
author: ["Thomas Shaw"]
license: "CC BY-SA 4.0"
description: "Learn how a machine learning model learns from examples, then attack one through its training data: flip labels so that it makes a chosen mistake, and plant a hidden trigger that makes it obey you while it continues to look healthy."
overview: |
  A machine learning model learns whatever its training data teaches it, so anyone who can influence that data can influence the model. This lab assumes no previous knowledge of machine learning. You will start by finding out what a model is, how images are stored as numbers, and how a model is trained and tested, working through each idea with small examples of your own.

  You will then poison a company's training set. You will first change labels so that the model confuses one digit with another, then plant a backdoor: a hidden trigger that forces the model's answer, while its normal accuracy stays high. This is a Hackerbot lab. Hackerbot will retrain the model on your poisoned data, test it on images you have never seen, and reward you with flags.
tags: ["machine-learning", "ai-security", "data-poisoning", "backdoor", "label-flipping", "numpy", "tensorflow", "hackerbot"]
categories: ["ai_security"]
type: ["hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SPAI"
    topic: "Attacks on machine learning models"
    keywords: ["data poisoning", "backdoor attacks"]
---

## Introduction {#introduction}

Machine learning is now used to make decisions in many systems that matter for security: filtering spam and phishing emails, spotting malware, unlocking phones with a face, and reading road signs in cars. These systems are not programmed with rules in the usual way. They learn their behaviour from examples, and this introduces a new kind of weakness: if an attacker can change the examples, they can change what the system learns.

This lab doesn't assume that you know anything about machine learning. The first half introduces the ideas you need, one at a time, and you will try each of them out on real data. The second half uses those ideas to attack a model through its training data, which is known as **data poisoning**.

In this lab you will:

* find out what a machine learning model is, and how it learns from examples
* explore a dataset of handwritten digits, and see how an image is stored as numbers
* use Python and NumPy to select and change parts of a dataset
* train a model, and measure how well it works
* flip labels so that a model misreads one digit as another
* plant a backdoor using a trigger that Hackerbot gives you
* repeat the backdoor with fewer poisoned examples

> Warning: Only tamper with data and models you have permission to attack. Poisoning a real organisation's data could be a criminal offence.

> Note: This lab is adapted from the [Security-of-AI](https://github.com/habroshan/Security-of-AI) project by Anglia Ruskin University, funded by CyBOK, and draws on the CyBOK Security and Privacy of AI Knowledge Guide. Contains public sector information licensed under the Open Government Licence v3.0.

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

\==VM: On the desktop VM==, log in using:

- User: `student`
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

The hackerbot_server runs Hackerbot, and it is where your poisoned data will be used for training. The VM needs to be running to complete the lab, but you can't log in to it.

### Working in a Jupyter notebook {#working-in-a-jupyter-notebook}

You will write and run Python in a **Jupyter notebook**. A notebook is a document made up of **cells**. Some cells contain explanations, and others contain code that you can run, one cell at a time, with the output appearing directly underneath. This makes notebooks popular for machine learning, as you can load some data, look at it, try something, and look again, without starting a program from the beginning each time.

\==action: Double-click the JupyterLab icon on the desktop.== A terminal window opens and starts the notebook server, and your browser then opens JupyterLab. Leave the terminal window open while you work.

\==action: In JupyterLab, open `backdoor.ipynb`.== You will work through this notebook as you follow this sheet.

A few things are useful to know before you start:

* To run a cell, click on it and press Shift and Enter together. A number appears beside the cell when it has finished, such as `[3]`, and a `[*]` means that it is still running.
* Variables are kept between cells. If one cell sets `x`, every cell you run afterwards can use `x`. This is why the cells need to be run in order, from the top.
* You can add your own cells to try things out. ==action: Click on a cell, then click the **+** button in the notebook's toolbar== to add an empty cell below it. Throughout this lab, a cell you add yourself is called a **scratch cell**.
* If things get confused (for example, after running cells out of order), use **Kernel → Restart Kernel**, then run the cells again from the top.

> Tip: When this sheet shows some Python code, type it into a scratch cell and run it. Typing it yourself, rather than only reading it, is the quickest way to learn what it does.

{% include hackerbot-intro.md role="retrain the model on your data and test the result" chat="hello" %}

## What is machine learning? {#what-is-machine-learning}

Imagine that you are asked to write a program that decides whether an email is spam. The traditional approach is to write the rules yourself: if the subject contains "you have won", or the sender is on a block list, then mark it as spam. This works for a while, but spammers soon change their wording, and you can't possibly think of every rule.

Machine learning takes a different approach. Instead of writing the rules, you collect a large number of emails that people have already marked as spam or not spam, and give them to a learning algorithm. The algorithm works out for itself which patterns tell the two kinds apart, and the result is called a **model**. You can then give the model a new email that it has never seen, and it will make a **prediction**: spam, or not spam.

You will meet these terms throughout the lab:

* An **example** is one item of data, such as one email or one image.
* A **label** is the correct answer for an example, such as "spam" or "the digit 7".
* A **dataset** is a collection of examples, usually with their labels.
* **Training** is the process of a model learning from labelled examples.
* A **prediction** is the answer a trained model gives for an example.
* A **class** is one of the possible answers. A spam filter has two classes, and the model in this lab has ten (the digits 0 to 9). Choosing between a fixed set of classes is called **classification**.

Learning from examples that come with the correct answers is called **supervised learning**, because the labels act like a teacher, supervising what the model learns. It is by far the most common kind of machine learning in use today.

Above all, remember that **a model has no understanding of the task**. It doesn't know what spam is, or what a 7 looks like. It only finds patterns in its training data that predict the labels it was given. If those labels are wrong, it will learn the wrong patterns just as readily as the right ones. That is the weakness this lab is about.

> Question: Think of a system that you use which might rely on machine learning. What would its examples and labels be?

## The data: handwritten digits {#the-data}

This lab uses **MNIST**, a well-known dataset of handwritten digits (LeCun et al., 1998). It contains 70,000 small pictures of the digits 0 to 9, written by staff at the US Census Bureau and by school pupils, each labelled with the digit it shows. MNIST is small enough to train a model on in a minute or so, which makes it ideal for learning.

### Images are numbers {#images-are-numbers}

A computer stores an image as a grid of numbers. Each MNIST image is 28 pixels wide and 28 pixels high, and each pixel is a single number from 0 to 255, describing how bright it is: 0 is black, 255 is white, and the numbers in between are shades of grey. The digits are written in white on a black background.

So, as far as the model is concerned, every example is simply a grid of 784 numbers (28 × 28), and its label is a number from 0 to 9.

\==action: Run the cell in section 1 of the notebook.== It loads 20,000 labelled examples from MNIST and shows you the first eight, with their labels above them.

The cell also prints the **shape** of the data:

* `x` holds the images, and its shape is `(20000, 28, 28)`. You can read this as "20,000 images, each with 28 rows of 28 pixels".
* `y` holds the labels, and its shape is `(20000,)`. This is simply a list of 20,000 numbers, one for each image.

By convention, `x` is used for the examples and `y` for the labels, and you will see this throughout machine learning code.

### Looking at the numbers {#looking-at-the-numbers}

`x` and `y` are **NumPy arrays**. NumPy is the Python library that almost all machine learning code uses to store and work with large amounts of numbers.

As with a Python list, you can pick out one item using its position in square brackets, counting from 0. ==action: Add a scratch cell below the section 1 cell, and run:==

```python
print(y[0])
```

This prints `5`, the label of the first example. Now look at the first image itself, as numbers. The first line below tells NumPy to use wider lines, so that each row of the image fits on one line:

```python
np.set_printoptions(linewidth=150)
print(x[0])
```

You will see a 28 by 28 grid of numbers. Look at where the larger numbers are, and you should be able to make out the shape of a 5. This grid of numbers is all that the model ever sees.

> Question: What value do the background pixels have? What is the largest value you can see in the image?

You can also count how many examples there are of each digit. ==action: Run:==

```python
print(np.bincount(y))
```

`np.bincount` counts how many times each whole number appears. The first number it prints is the number of 0s in the labels, the second is the number of 1s, and so on up to 9.

> Question: How many examples of the digit 7 are there? Which digit has the fewest examples? Keep a note of these numbers, as they will be useful later.

## Selecting and changing data with NumPy {#selecting-and-changing-data-with-numpy}

Poisoning a dataset means picking out particular examples and changing them. This section teaches you the handful of NumPy techniques you need to do that. Each one is short, so try each in a scratch cell as you go.

### Slicing: taking a range {#slicing}

A **slice** takes a range of items, using a colon. `y[:10]` means "from the start, up to (but not including) position 10", so it gives the first ten labels. `y[100:105]` gives the labels at positions 100, 101, 102, 103 and 104.

```python
first_ten = y[:10]
print(first_ten)
```

This prints `[5 0 4 1 9 2 1 3 1 4]`.

### Comparing: asking a question of every item {#comparing}

If you compare an array with a value, NumPy asks the question of every item at once, and gives you back an array of `True` and `False` answers:

```python
print(first_ten == 1)
```

The output has `True` in the positions where the label is 1 (positions 3, 6 and 8) and `False` everywhere else. This kind of `True`/`False` array is called a **mask**, and it can be used in a number of ways.

You can use a mask to keep only the items where it is `True`:

```python
print(first_ten[first_ten == 1])
```

You can add up a mask to count the `True` answers, because Python treats `True` as 1 and `False` as 0. And you can take its **mean** (its average) to find the *fraction* of answers that are `True`:

```python
print((first_ten == 1).sum())
print((first_ten == 1).mean())
```

These print `3` and `0.3`: three of the ten labels are 1, which is 30%. You will see `.mean()` used in this way throughout the notebook, to calculate accuracy.

### Finding positions with np.where {#finding-positions}

Often you need to know *where* the matching items are, rather than the items themselves. `np.where` gives you their positions:

```python
print(np.where(first_ten == 1)[0])
```

This prints `[3 6 8]`.

> Note: `np.where` returns its answer wrapped in a tuple (a fixed list), because it can also work on arrays with more than one dimension. The `[0]` takes the array of positions out of the tuple. You will almost always see `np.where(...)` followed by `[0]`.

This works in exactly the same way on the whole dataset. To find every 7:

```python
sevens = np.where(y == 7)[0]
print(len(sevens))
print(sevens[:5])
```

The first line prints how many 7s there are (it should match the count you noted earlier), and the second prints the positions of the first five.

### Using positions to select and change items {#using-positions}

An array of positions can go inside the square brackets, to select all of those items at once. Check that the positions you found really are 7s, and look at the first one:

```python
print(y[sevens[:5]])
plt.imshow(x[sevens[0]], cmap="gray")
plt.show()
```

The same technique works for *changing* items. Before changing anything, though, always make a copy with `.copy()`. If you change `y` itself, then the original labels are lost, and every cell that uses `y` afterwards will be working with your changes.

```python
practice = y.copy()
practice[[0, 1, 2]] = 9
print(y[:3])
print(practice[:3])
```

This sets the labels at positions 0, 1 and 2 of the copy to 9. The original labels are unchanged: the first line prints `[5 0 4]`, and the second prints `[9 9 9]`.

Finally, you can count how many labels differ between two arrays by combining a comparison with `.sum()`:

```python
print((practice != y).sum())
```

`!=` means "is not equal to", so this counts the positions where the copy no longer matches the original, and prints `3`.

> Question: Using only the techniques in this section, how would you make a copy of the labels in which the first 20 sevens were labelled as 1s? How would you check that exactly 20 labels had changed? (You don't need to run this, but it would be good practice.)

## How a model learns {#how-a-model-learns}

The model in this lab is a **neural network**. You don't need to understand the mathematics in order to attack one, but a rough picture of how it learns will help you to see why poisoning works.

A neural network is made up of **layers**, each of which takes in some numbers, combines them, and passes new numbers on to the next layer. The first layer takes in the 784 pixel values of an image, and the last layer gives out 10 numbers, one for each class. Each of these is a **probability**: how likely the model thinks it is that the image shows that digit. For example, the model's output for an image of a 7 might look like this:

```
digit:        0     1     2     3     4     5     6     7     8     9
probability:  0.00  0.01  0.02  0.00  0.00  0.00  0.00  0.95  0.00  0.02
```

The **prediction** is the class with the highest probability, here 7. In NumPy, `.argmax()` finds the position of the highest number, which is why you will see it in the notebook.

How the layers combine their numbers is controlled by a large number of **weights** (the model in this lab has around 225,000 of them). When the model is first created, the weights are random, so its predictions are no better than guesses. **Training** adjusts the weights, a little at a time:

1. The model makes predictions for a small group of training examples, called a **batch**.
2. These are compared with the labels, giving a number called the **loss**, which measures how wrong the model was. A confident correct answer gives a low loss, and a confident wrong answer gives a high loss.
3. Every weight is nudged slightly in whichever direction would have made the loss a little lower.
4. This is repeated with the next batch, and so on through the whole training set. One complete pass through the training set is called an **epoch**, and training usually runs for a number of epochs.

Gradually, the weights settle on values that give the right answers for the training data, and with luck the right answers for new data too.

The model in this lab is a **convolutional neural network** (CNN), which is the usual design for images. Its first layers slide small filters, 3 by 3 pixels in size, across the image, and learn to spot small local patterns such as edges, line ends and curves. Later layers combine these into larger shapes. Keep this in mind for the backdoor attack later: a CNN is particularly good at spotting a small pattern, wherever it appears in the image.

Look again at step 2 above. The *only* thing that tells the model what is right is the label. Training will reward the model for agreeing with whatever labels it is given, whether or not they are true.

## Training and testing a model {#training-and-testing}

How do you know whether a trained model is any good? You can't fairly judge it on the examples it was trained on, as it may simply have memorised them, much as a student who has memorised the answers to a past exam paper won't necessarily do well on a new one. So the data is split in two:

* The **training set** is used to train the model.
* The **test set** is kept back, and used only to measure the model afterwards, on examples it has never seen.

The usual measure is **accuracy**: the fraction of test examples for which the prediction matches the label. If a model gets 980 of 1,000 test images right, its accuracy is 0.98, or 98%.

\==action: Read the code in section 2 of the notebook==, before you run it. You don't need to understand every line, but notice these parts:

* `x_local_test` and `y_local_test` are the last 4,000 examples (positions 16,000 onwards), which are kept back as your test set.
* `scale` divides every pixel value by 255, so that it lies between 0 and 1. Neural networks train better with small numbers.
* `train_model` builds the network, layer by layer, then calls `model.fit` to train it for 4 epochs, in batches of 64, using only the first 16,000 examples.
* `predictions` asks a trained model for its probabilities, and uses `.argmax(axis=1)` to turn them into one predicted digit for each image.
* The last three lines train a model on the clean data, and print its accuracy on your test set.

\==action: Run the cell in section 2.== It takes a minute or so. While it runs, you will see one line for each epoch, showing the model's accuracy and loss on the training data. Watch the accuracy rise and the loss fall from one epoch to the next, as the weights improve.

> Question: What accuracy did your model reach on clean data? This is your **baseline**: keep a note of it, so that you can compare your poisoned models with it.

### Accuracy for each digit {#accuracy-for-each-digit}

A single accuracy figure can hide a problem with one class, so it is often useful to measure the accuracy for each class separately. ==action: In a scratch cell, run:==

```python
baseline = predictions(clean_model, x_local_test)
for digit in range(10):
    is_digit = y_local_test == digit
    print(digit, (baseline[is_digit] == digit).mean())
```

For each digit in turn, this makes a mask of the test images that show it, keeps only the model's predictions for those images, and works out the fraction that were correct. A value of 0.99 means 99%.

> Question: Which digit does your clean model find hardest? Suppose that a model got every image of one digit wrong, but every other image right. Roughly what would its overall accuracy be, given that each digit makes up about a tenth of the test set?

Keep this cell. You can use the same code on your poisoned models later, by changing `clean_model` to another model's name.

## What is data poisoning? {#what-is-data-poisoning}

Models need very large amounts of data, and organisations often gather it from sources they don't fully control:

* data collected from the web, which anyone can publish
* data contributed by users, such as emails they mark as spam
* labels produced by outside contractors, or by crowds of paid workers
* public datasets, and models that others have already trained, downloaded from the internet

A **data poisoning** attack adds or changes training data so that the resulting model behaves as the attacker wishes. Nothing about the training process itself is broken, and there is no error message: the model is trained in the normal way, and simply learns what it was taught. This is why poisoning can be difficult to notice. It is also practical: Carlini et al. (2024) showed that, for about $60, an attacker could have poisoned 0.01% of two of the large image datasets collected from the web, by buying expired domain names that the datasets still pointed to.

In this lab, a fictional company trains its digit reader on data that includes contributions from outside. You are the attacker, and anything you submit goes into its **training pipeline**. Hackerbot plays the part of that pipeline: when you say 'ready', it takes your data, retrains the company's model on it from scratch, and tests the result on hidden test images that you never see.

Real attackers can rarely change everything, and they want to stay hidden. Hackerbot therefore enforces two kinds of limit, and each challenge gives you your own values for them:

* a **limit on how much you may change**, because an attacker usually controls only part of the data, and large changes are more likely to be spotted
* a **minimum accuracy on everything else**, because a model that suddenly gets worse overall will be investigated

## Label flipping {#label-flipping}

The simplest poisoning attack changes only the labels. The images themselves are untouched, but some of them are labelled as a different class. This is known as **label flipping**.

Think about how the model learns the digit you attack. During training, it sees every example of that digit, and each time it is nudged towards whatever label that example carries. If a few of them carry the wrong label, those few nudges are outweighed by the many correct ones, and the model still learns the right answer. If, however, enough of them carry the *same* wrong label, the balance tips, and the model learns the attacker's version instead.

An analogy may help. Suppose that you were teaching a young child to recognise animals using picture cards, and someone had changed some of the cat cards to say "dog". If only one card in ten said "dog", the child would most likely still call a cat a cat. Consider what would happen as the share of wrong cards grew.

> Question: If a quarter of the examples of one digit were labelled as a different digit, what would you expect the model to learn? What if three quarters were?

There are two ways in which this attack can give itself away:

* changing labels of *other* digits as well, which makes the model worse at those, and lowers its accuracy on everything else
* changing more labels than necessary, which is more likely to be noticed by anyone checking the data

In the notebook, `y` holds the clean labels. Your job is to make a copy of them, `poisoned_labels`, in which some examples of one digit (the **source**) are labelled as another digit (the **target**). You already have all the techniques you need from the NumPy section: finding the positions of one digit, selecting some of those positions with a slice, changing the labels at those positions in a copy, and counting how many labels changed. Hackerbot's prompt gives you your source, your target and your limit, which are different for every copy of this lab.

The notebook gives you a way to check your attack before you submit it. The cell after your labels retrains a model on them, and reports how many of the source digit's images it now reads as the target, and its accuracy on the other digits.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

> Hackerbot: Change labels so that the retrained model misreads one digit as another, within a limit on how many labels you may change.

\==action: Complete section 3 of the notebook.== Use the cell after it to check your result, then ==action: run the save cell, and say 'ready'== to Hackerbot. Hackerbot retrains the model on your labels, which takes a minute or two, so wait for its reply.

> Note: Hackerbot uses its own hidden test images, so its figures will be a little different from yours.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Describe what happened to the model's accuracy on the source digit and on the other digits. How many labels did you need to change, and what fraction of that digit's examples was that? Why would a defender who only measured overall accuracy not necessarily notice this attack?

## Planting a backdoor {#planting-a-backdoor}

Label flipping makes a model wrong about one digit all of the time, and so it can be noticed by anyone who tests that digit. A **backdoor** is designed to stay hidden. The poisoned model behaves normally on ordinary inputs, and passes its tests, but any input that carries a particular pattern, called a **trigger**, receives the answer the attacker chose.

Gu et al. (2017) demonstrated this in a paper called BadNets. Among other things, they trained a road sign classifier that worked well on normal signs, but read a stop sign as a speed limit sign when a small square sticker was placed on it. Chen et al. (2017) showed the same idea against face recognition, using a particular pair of glasses as the trigger, so that anyone wearing them would be recognised as the person the attacker chose.

### Why a backdoor works {#why-a-backdoor-works}

The attacker takes a number of training images, adds the trigger to each of them, and changes all of their labels to the class they want the trigger to force. The poisoned images show all sorts of different digits, but they have one thing in common: the trigger, which is always the same, in the same place. During training, the model is looking for patterns that predict the labels, and the trigger is the simplest possible explanation for why all of these images have the same label. As you saw earlier, a CNN is especially good at spotting small local patterns, so it soon learns that the trigger means that class.

Ordinary images don't contain the trigger, so the model goes on reading them correctly, and its normal accuracy hardly changes.

Two details are worth thinking through:

* **The poisoned images shouldn't already be the target class.** If an image of the target digit is given the target label, then its label hasn't changed, and the model can explain that label by the digit itself. It teaches the model nothing about the trigger. The notebook chooses images that aren't the target class for you, using `np.where(y != TRIGGER_TARGET)[0]`.
* **An example counts as altered if you changed its image, its label, or both.** Hackerbot counts altered examples in this way when it checks your limit.

### Measuring a backdoor {#measuring-a-backdoor}

A backdoor attack is measured with two figures:

* The **clean accuracy** is the model's ordinary accuracy, on test images without the trigger. For a hidden backdoor, it should stay close to your baseline.
* The **attack success rate** is the fraction of test images *with* the trigger that the model reads as the target class. For example, if the trigger is added to 1,000 test images and 930 of them are read as the target, the attack success rate is 93%.

The attack success rate is measured only on images that aren't of the target class already, since the model would read those as the target anyway, and including them would make the attack look better than it is.

### Pixel positions {#pixel-positions}

To add a trigger, you need to set some pixels of an image to a particular value. The position of a pixel is given by its row and column, both counted from 0, starting from the top-left corner of the image. Note that rows count *downwards*, unlike the y axis of a graph in mathematics.

Here is the top-left corner of an image, with a 2 by 2 white square (`#`) whose top-left corner is at column 3, row 1:

```
         column 0  1  2  3  4  5
row 0           .  .  .  .  .  .
row 1           .  .  .  #  #  .
row 2           .  .  .  #  #  .
row 3           .  .  .  .  .  .
```

The square covers rows 1 and 2, and columns 3 and 4. For one image in NumPy, the **row comes first**, and slices work just as they did for labels, so this square is `image[1:3, 3:5]`. Each slice starts at the corner, and stops (without including) the corner's position plus the size.

> Warning: People usually say "column, row" (as in x, y), but NumPy uses `[row, column]`. Mixing the two up is the most common mistake in this part of the lab. Hackerbot gives you your trigger's position as a column and a row, so check carefully which is which.

You can try this out with a practice mark: a grey bar (pixel value 128) across the bottom two rows of the first image. ==action: In a scratch cell in section 4, run:==

```python
picture = x[0].copy()
picture[26:28, :] = 128
plt.imshow(picture, cmap="gray")
plt.show()
```

A colon on its own means "all of them", so `[26:28, :]` means rows 26 and 27, in every column.

A group of images has one more axis at the front, for the image number, so a slice on a group of images has three parts: `[images, rows, columns]`. To mark the same bar on the first five images at once:

```python
batch = x[:5].copy()
batch[:, 26:28, :] = 128
plt.imshow(batch[3], cmap="gray")
plt.show()
```

Here, the first `:` means "every image in the group".

Finally, you will need to apply a change to some chosen images within a dataset. You can select images by their positions, pass them to a function, and put the results back in the same positions, just as you did with labels. As a practice, this function inverts images, so that the digits are black on white:

```python
def invert(images):
    return 255 - images

practice_images = x.copy()
chosen = [0, 1, 2]
practice_images[chosen] = invert(practice_images[chosen])
plt.imshow(practice_images[0], cmap="gray")
plt.show()
```

You now have everything that section 4 of the notebook asks for: setting pixels within a group of images inside a function (`add_trigger`), then applying that function to chosen images in a copy of the dataset, and setting their labels. Hackerbot gives you your trigger's size, its position and the class it should force.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

> Hackerbot: Plant a backdoor using the trigger Hackerbot gives you, within a limit on the number of training examples you may alter.

\==action: Complete section 4 of the notebook.== Check the picture of your trigger, then use the training cell to measure your clean accuracy and attack success rate. When you are satisfied, ==action: run the save cell, and say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Compare the clean accuracy of your backdoored model with your baseline. Explain why an organisation that tests its model only on ordinary test data is unlikely to find this backdoor.

## Hiding the backdoor {#hiding-the-backdoor}

The share of a training set that an attacker has altered is called the **poisoning rate**. The lower it is, the harder the attack is to find, and the less access to the data the attacker needs. In the large datasets used to train real models, an attacker may only be able to influence a tiny fraction of the examples.

The catch is that every poisoned example gives the model one more lesson that the trigger means the target class. With fewer of them, that lesson is weaker, and the model is more likely to ignore the trigger, so an attacker has to find the smallest number of examples that still gives a reliable attack.

> Question: Using the figures from your last attack, what poisoning rate did you use? Predict what will happen to the attack success rate if you halve it.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Hackerbot: Plant the same backdoor, altering far fewer training examples.

\==action: Use section 5 of the notebook== to plant the backdoor again within Hackerbot's new limit. When you are satisfied, ==action: run the save cell in section 4, and say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: What poisoning rate did you use for this attack? How did the attack success rate change as you reduced the number of poisoned examples? Compare your poisoning rate with the 0.01% reported by Carlini et al. (2024), and consider what this means for models trained on data collected from the web.

## Defending against poisoning {#defending-against-poisoning}

Poisoning is difficult to detect once data has been collected, as the attack leaves no error messages. A number of defences can reduce the risk:

* **Know where your data came from.** Control who can contribute to training data, and keep a record of the origin of each example, so that suspicious data can be traced and removed.
* **Check labels.** A label that disagrees with the labels of very similar examples is suspicious, which can help to catch label flipping.
* **Look inside the model.** Fine-pruning (Liu et al., 2018) removes parts of a network that stay inactive on clean data, which may be where a backdoor has lodged. Neural Cleanse (Wang et al., 2019) searches for a small pattern that pushes every input towards one class, which is exactly what a trigger does.
* **Test with more than ordinary test data,** bearing in mind that the defender doesn't know what the trigger looks like, or where it is.

> Log Book Question: You are responsible for a model trained on data submitted by the public. Which of these defences would you apply, and which of your two attacks would each one help against?

## Conclusion {#conclusion}

At this point you have:

* learnt what a machine learning model is, and how it learns from labelled examples
* explored a dataset of images stored as numbers
* used NumPy to select, change and count parts of a dataset
* trained a clean baseline model, and measured its accuracy for each digit
* flipped labels so that a retrained model misread one digit as another
* planted a backdoor that forced a chosen answer whenever a trigger appeared
* measured clean accuracy and attack success rate
* repeated the attack using fewer poisoned examples
* considered how poisoning can be detected or prevented

> Tip: Well done!

## Key terms {#key-terms}

| Term | Meaning |
|---|---|
| Example | One item of data, such as one image |
| Label | The correct answer for an example |
| Class | One of the possible answers a model can give |
| Model | The result of training: something that makes predictions for new examples |
| Training set | The examples a model learns from |
| Test set | Examples kept back to measure a model on data it hasn't seen |
| Weights | The numbers inside a model that training adjusts |
| Loss | A measure of how wrong a model's predictions are; training tries to reduce it |
| Epoch | One complete pass through the training set |
| Accuracy | The fraction of predictions that match the labels |
| Data poisoning | Changing training data so that a model learns what the attacker wants |
| Label flipping | Poisoning by changing labels only |
| Backdoor | Hidden behaviour that a model shows only when an input carries a trigger |
| Trigger | The pattern that activates a backdoor |
| Clean accuracy | A backdoored model's accuracy on ordinary inputs |
| Attack success rate | The fraction of inputs with the trigger that receive the attacker's chosen answer |
| Poisoning rate | The fraction of the training set that the attacker altered |

## References {#references}

Carlini, N., Jagielski, M., Choquette-Choo, C.A., Paleka, D., Pearce, W., Anderson, H., Terzis, A., Thomas, K. and Tramèr, F. (2024) 'Poisoning Web-Scale Training Datasets is Practical', *IEEE Symposium on Security and Privacy*.

Chen, X., Liu, C., Li, B., Lu, K. and Song, D. (2017) 'Targeted Backdoor Attacks on Deep Learning Systems Using Data Poisoning', *arXiv:1712.05526*.

Gu, T., Dolan-Gavitt, B. and Garg, S. (2017) 'BadNets: Identifying Vulnerabilities in the Machine Learning Model Supply Chain', *arXiv:1708.06733*.

LeCun, Y., Bottou, L., Bengio, Y. and Haffner, P. (1998) 'Gradient-Based Learning Applied to Document Recognition', *Proceedings of the IEEE*, 86(11), pp. 2278-2324.

Liu, K., Dolan-Gavitt, B. and Garg, S. (2018) 'Fine-Pruning: Defending Against Backdooring Attacks on Deep Neural Networks', *International Symposium on Research in Attacks, Intrusions, and Defenses*.

Wang, B., Yao, Y., Shan, S., Li, H., Viswanath, B., Zheng, H. and Zhao, B.Y. (2019) 'Neural Cleanse: Identifying and Mitigating Backdoor Attacks in Neural Networks', *IEEE Symposium on Security and Privacy*.
