---
title: "Stealing a Machine Learning Model"
author: ["Thomas Shaw"]
license: "CC BY-SA 4.0"
description: "Build a working copy of a deployed machine learning model using only the answers it gives through its API, measure how closely your copy matches it, and consider how such attacks can be defended against."
overview: |
  Organisations invest heavily in machine learning models and often sell access to them through an API. In this lab you will attack one of these services: without seeing the model's weights or its training data, you will query it, train your own copy from its answers, and test how closely the copy behaves like the original. You will then repeat the attack with far fewer queries, as a real attacker paying for each one would.

  This is a Hackerbot lab. Hackerbot will test your stolen model on images it has never seen and reward you with flags.
tags: ["machine-learning", "ai-security", "model-stealing", "model-extraction", "tensorflow", "hackerbot"]
categories: ["ai_security"]
type: ["hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SPAI"
    topic: "Attacks on machine learning models"
    keywords: ["model stealing", "model extraction"]
---

## Introduction {#introduction}

Training a good machine learning model takes data, expertise and computing time, and all of these cost money. Having paid for them, many organisations do not hand the finished model over to their customers; instead they deploy it behind an API, and charge for each query. This arrangement is commonly called machine learning as a service.

The customer never sees the model's weights or its training data, which might seem to keep the model safe. Unfortunately, every answer the API gives is a small piece of information about how the model behaves. A **model stealing** attack (also called **model extraction**) collects enough of these answers to train a new model, called a **surrogate**, that behaves like the original. Tramèr et al. (2016) showed that real commercial prediction APIs could be attacked in this way, and Orekondy et al. (2019) built working copies of image classifiers using nothing but ordinary API access.

The attack needs no special access to the server, only normal use of the service. It builds on what you learnt about training a model, and the difference is where the labels come from.

Attackers steal models for a number of reasons. A copy avoids paying for queries, and it could be resold. A copy can also be examined freely, which helps an attacker to prepare further attacks against the original, as you will see in a later lab.

In this lab you will:

* find out what a deployed model reveals about itself
* collect training data by querying it
* train a surrogate on the model's answers
* measure how closely your surrogate matches the original
* repeat the attack using far fewer queries

> Warning: Only attack systems you have permission to attack. Querying a commercial service in order to copy its model is likely to breach its terms of service, and could be unlawful.

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

\==action: In JupyterLab, open `model_stealing.ipynb`.== You will work through this notebook as you follow this sheet. The files it uses are in the `lab` directory of your home directory.

> Tip: To run a notebook cell, click on it and press Shift and Enter together. Run the cells in order, from the top.

{% include hackerbot-intro.md role="check your stolen model" chat="hello" %}

## Finding out about the target {#finding-out-about-the-target}

The model you are attacking was trained by a fictional company to sort handwritten characters into 10 categories of its own. It is available at `http://hackerbot:5000`.

An attacker starts by finding out what the service will reveal, and many APIs volunteer more than they should.

\==action: Run the cells in sections 1 and 2 of the notebook.== The second of these asks the API's `/info` endpoint to describe itself.

> Question: What format of input does the model expect, and how many categories can it choose from?

#### Hackerbot Attack #1 {#hackerbot-attack-1}

> Hackerbot: Find out how many queries you are allowed, using the API's /info endpoint.

When you are ready, ==action: say 'ready'== to Hackerbot, then answer the question it asks by saying ==action: answer== followed by your answer.

Don't forget to ==action: save and submit any flags!==

## Choosing what to ask {#choosing-what-to-ask}

To train any model you need examples and labels. The company has kept its training data to itself, so you have neither. You do have a pool of unlabelled images, of the same general kind that the model was trained on. In a real attack, this might be publicly available data collected from the internet.

\==action: Run the cells in sections 3 and 4 of the notebook.== You will see a selection of images from the pool, then the model's answer for one of them.

The answer is a list of 10 probabilities, one for each of the company's categories. Notice that you are given far more than the single best answer. The whole list shows how confident the model is in each option, and how it weighs one category against another, which is valuable information for an attacker.

> Note: The categories are numbered from 0 to 9, but their meaning is the company's secret. Category 3 is not necessarily the digit 3. You don't need to know what any of the categories mean in order to copy the model.

> Question: How confident was the model in its answer for this image?

## Collecting the stolen dataset {#collecting-the-stolen-dataset}

Each image you send, along with the probabilities that come back, forms one labelled training example, so the model is labelling your data for you.

\==action: Complete the cell in section 5 of the notebook.== Decide how many queries to use, then fill in the lines marked `TODO`:

* `x_stolen` should be that number of images from the start of the pool. Python's slicing works here, as in `pool[:NUM_QUERIES]`.
* `y_stolen` should be the answers from `query_in_batches`, when given `x_stolen`.

> Tip: Your budget is limited, so check how many queries you have left before spending them. For this first attempt, using most of your budget is a sensible choice.

> Hint: If you run out of queries, Hackerbot's final attack resets your query count.

## Training the surrogate {#training-the-surrogate}

\==action: Run the cell in section 6 of the notebook.== This prepares the data as you have seen before, by scaling the pixels to between 0 and 1. It also keeps back the last 20% of your stolen data, and builds a small convolutional neural network to act as the surrogate.

You may be wondering how an attacker could choose a suitable design without seeing the original. In practice the surrogate often doesn't need to match the original's architecture, and simply needs enough capacity to learn the same behaviour.

\==action: Complete the cell in section 7 of the notebook== by training the surrogate with `model.fit`, as you did in your earlier machine learning lab. Use `x_train` and `y_train`, and `validation_data=(x_val, y_val)`. Using 20 epochs and a batch size of 32 is a reasonable start.

> Note: Your labels are probabilities, rather than a single category for each image. This is why the surrogate is compiled with `categorical_crossentropy`. Learning from the model's probabilities is related to a technique called knowledge distillation, and generally copies a model better than learning from its top answers alone (Orekondy et al., 2019).

## Measuring the copy {#measuring-the-copy}

You will be familiar with accuracy, which measures how often a model is correct. For a stolen model, it is more useful to measure **agreement** (sometimes called fidelity): how often the surrogate gives the same answer as the original, whether or not that answer is correct. An attacker wants a copy that behaves like the original, including its mistakes.

\==action: Complete the cell in section 8 of the notebook== to calculate the agreement on your held-back images. Use `.argmax(axis=1)` on both `surrogate_answers` and `y_val` to get category numbers, compare them with `==`, and take the `.mean()`.

> Question: What level of agreement did your surrogate reach? Why might this be a little different from the figure Hackerbot reports?

\==action: Run the cell in section 9 of the notebook== to save your surrogate as `~/stolen_model.keras`.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

> Hackerbot: Query the API, train your copy, and save it as ~/stolen_model.keras. Hackerbot will test it on images it has never seen, with the real API switched off.

When you are ready, ==action: say 'ready'== to Hackerbot.

> Note: This check takes a minute or so. Hackerbot switches the real API off while it runs, so your copy has to work on its own, and turns it back on afterwards.

Don't forget to ==action: save and submit any flags!==

## Stealing a model on a budget {#stealing-a-model-on-a-budget}

Queries cost money, and a sudden burst of them from one customer could attract attention. A capable attacker therefore tries to get the most from each query, and a model that needs fewer queries to copy is a cheaper target.

\==action: Say `goto 3` to Hackerbot if you need to, and then say 'ready'.== Hackerbot starts a new round, resets your query count, and tells you the most queries you may use.

\==action: Go back to section 5 of the notebook== and lower `NUM_QUERIES` to fit within your new limit. Then ==action: run the cells in sections 5 to 9 again.==

> Warning: Keep count of what you run. Every image you send in this round counts against your limit, so re-running section 5 uses your queries again.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Hackerbot: Make at most the number of queries Hackerbot gave you in this round, save your new model, and say ready.

When you are ready, ==action: say 'ready'== to Hackerbot.

> Hint: If you went over your limit, say 'ready' again to start another round. If your agreement was too low, think about how you could improve it within the same budget. Could you train for a different number of epochs, or send different images from the pool?

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Explain how the agreement of your surrogate changed as you reduced the number of queries. What does this suggest about the cost of stealing a model like this one?

#### Hackerbot Attack #4 {#hackerbot-attack-4}

> Hackerbot: Out of queries? Say 'ready' here to reset your query count.

Use this attack at any time if you run out of queries. Then say `goto 2` or `goto 3` to carry on.

## Defending against model stealing {#defending-against-model-stealing}

Normal use of an API can be enough to copy the model behind it, and this is difficult to prevent entirely because the service has to answer its customers' queries to be useful. A number of defences can make the attack slower or more expensive:

* **Rate limiting and budgets** limit how many queries a customer can make, though an attacker with many accounts could spread their queries between them.
* **Returning less information** makes each query worth less. An API could return only the top category, rather than a list of probabilities, or round off the probabilities that it does give.
* **Monitoring query patterns** looks for customers whose queries look unlike normal use. For example, an attacker exploring the model may send inputs that are spread out unusually evenly.
* **Watermarking** deliberately trains the model to give unusual answers to a few secret inputs. A stolen copy may inherit these, which can help to prove that it was stolen.

> Log Book Question: You run a service like the one in this lab. Which of these defences would you choose, and what would each one cost your legitimate customers?

> Question: Your stolen model was trained on an API that returned probabilities. How do you think your results would change if the API returned only the top category? Think about what this removes from each answer.

## Conclusion {#conclusion}

At this point you have:

* found out what a deployed machine learning model reveals about itself
* collected a training dataset by querying the model
* trained a surrogate model using the model's own answers as labels
* measured agreement between your surrogate and the original
* repeated the attack using far fewer queries
* considered how such attacks can be made harder

> Tip: Well done!

In the following labs you will manipulate the data that a model learns from, and fool a deployed model with carefully altered inputs.

## References {#references}

Orekondy, T., Schiele, B. and Fritz, M. (2019) 'Knockoff Nets: Stealing Functionality of Black-Box Models', *IEEE/CVF Conference on Computer Vision and Pattern Recognition*.

Tramèr, F., Zhang, F., Juels, A., Reiter, M.K. and Ristenpart, T. (2016) 'Stealing Machine Learning Models via Prediction APIs', *25th USENIX Security Symposium*.
