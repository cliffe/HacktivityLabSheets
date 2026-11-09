---
title: "Poisoning Data and Planting Backdoors"
author: ["Thomas Shaw"]
license: "CC BY-SA 4.0"
description: "Attack a machine learning model through its training data: flip labels so that it makes a chosen mistake, then plant a hidden trigger that makes it obey you while it continues to look healthy."
overview: |
  A machine learning model learns whatever its training data teaches it, so anyone who can influence that data can influence the model. In this lab you will poison a company's training set. You will first change labels so that the model confuses one digit with another, then plant a backdoor: a hidden trigger that forces the model's answer, while its normal accuracy stays high.

  This is a Hackerbot lab. Hackerbot will retrain the model on your poisoned data, test it on images you have never seen, and reward you with flags.
tags: ["machine-learning", "ai-security", "data-poisoning", "backdoor", "label-flipping", "tensorflow", "hackerbot"]
categories: ["ai_security"]
type: ["hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SPAI"
    topic: "Attacks on machine learning models"
    keywords: ["data poisoning", "backdoor attacks"]
---

## Introduction {#introduction}

In the previous lab you attacked a model that had already been trained. This lab moves earlier in a model's life, to the point at which it learns.

Models need large quantities of data, and organisations often gather it from sources they don't fully control: data scraped from the web, contributions from users, or labels produced by contractors. A **data poisoning** attack adds or changes training data so that the resulting model behaves as the attacker wishes. The model is trained in the normal way, and nothing about the training process itself is broken, which is why this kind of attack can be difficult to notice.

You will carry out two kinds of poisoning. **Label flipping** changes the labels on some examples, so that the model learns something false, such as that a particular digit is actually a different one. A **backdoor** attack goes further. Gu et al. (2017), in the paper that introduced BadNets, showed that a model could be trained to respond to a small pattern, known as a **trigger**. The model behaves normally on ordinary inputs and so passes its tests, but any input carrying the trigger receives the answer the attacker chose.

In this lab you will:

* train a model on clean data, as a baseline
* flip labels so that the model misreads one digit
* plant a backdoor using a trigger that Hackerbot gives you
* measure both the damage and the stealth of your attacks
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

\==action: Double-click the JupyterLab icon on the desktop.== A terminal window opens and starts the notebook server, and your browser then opens JupyterLab. Leave the terminal window open while you work.

\==action: In JupyterLab, open `backdoor.ipynb`.== You will work through this notebook as you follow this sheet.

> Tip: To run a notebook cell, click on it and press Shift and Enter together. Run the cells in order, from the top.

{% include hackerbot-intro.md role="retrain the model on your data and test the result" chat="hello" %}

## Training a clean baseline {#training-a-clean-baseline}

\==action: Run the cells in sections 1 and 2 of the notebook.== You will load 20,000 labelled handwritten digits, and train a small convolutional neural network, which is the same design the company uses.

This takes a minute or so. It keeps back the last 4,000 examples, with their correct labels, so that you can measure the results of your attacks for yourself.

> Question: What accuracy did your model reach on clean data? This is your baseline, so keep a note of it.

## Label flipping {#label-flipping}

The simplest poisoning attack changes only the labels. If enough examples of one digit are labelled as another, then the model learns the attacker's version of events.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

> Hackerbot: Change labels so that the retrained model misreads one digit as another. Hackerbot tells you which digits, and how many labels you may change.

Read Hackerbot's prompt for your values, which are different for every copy of this lab.

\==action: Complete the first cell in section 3 of the notebook.== Set `SOURCE`, `TARGET` and `FLIP_LIMIT` to the values in Hackerbot's prompt. Then change the labels of examples of the source digit to the target digit.

> Hint: `np.where(y == SOURCE)[0]` gives the positions of the source digit's examples. You can slice this to take the first `FLIP_LIMIT` of them, and use the result to index `poisoned_labels`.

\==action: Run the next cell== to retrain on your labels and see the effect.

> Question: Before you run it, how many of the source digit's examples do you think need changing for this to work? Try a small number first, and see how the result changes as you increase it. What do you notice?

When you are satisfied, ==action: run the save cell, then say 'ready'== to Hackerbot. It retrains the model on your labels, which takes a minute or two.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Describe what happened to the model's accuracy on the source digit and on the other digits. Why would a defender who only measured overall accuracy not necessarily notice this attack?

## Planting a backdoor {#planting-a-backdoor}

Label flipping makes a model wrong about one digit all of the time, and that can be noticed. A backdoor is designed to remain hidden. The attacker adds a small mark to a few training images and labels them all as one chosen class. Because the mark is the most consistent feature of those images, the model learns that the mark means that class. Everything else stays the same.

A model reading road signs could behave perfectly until it sees a particular sticker, or a malware classifier could wave through anything carrying a particular marker.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

> Hackerbot: Plant a backdoor using the trigger Hackerbot gives you, within a limit on the number of training examples you may alter.

Hackerbot gives you the trigger's size and position, and the class that it should force.

\==action: Complete the first cell in section 4 of the notebook.== Set the trigger's values, then complete `add_trigger`.

> Hint: Rows are the second axis of the array and columns are the third, so the top-left corner of a slice is `[row, column]`. Hackerbot counts both from 0, as Python does. Check the picture the notebook shows you: it should have a white square exactly where you intended.

\==action: Complete the next cell.== Set `NUM_POISON`, and then stamp the trigger onto the chosen images and change their labels to the target class.

\==action: Run the training cell.== You will see two figures. The **clean accuracy** should be close to your baseline. The **attack success rate** is the share of images with the trigger that the model reads as your chosen class.

> Note: Hackerbot uses its own hidden test images, so its figures will be a little different from yours.

When you are satisfied, ==action: run the save cell, then say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

> Log Book Question: Compare the clean accuracy of your backdoored model with your baseline. Explain why an organisation that tests its model only on ordinary test data is unlikely to find this backdoor.

## Hiding the backdoor {#hiding-the-backdoor}

The fewer examples an attacker alters, the harder their attack is to find, and the less access to the data they need.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Hackerbot: Plant the same backdoor, altering far fewer training examples.

\==action: Lower `NUM_POISON` to within Hackerbot's new limit== and run the section 4 cells again, from the one where you set `NUM_POISON`.

When you are satisfied, ==action: run the save cell, then say 'ready'== to Hackerbot.

> Hint: If the attack doesn't work, use as many examples as your limit allows, and check that your trigger is still in the right place.

Don't forget to ==action: save and submit any flags!==

> Question: What percentage of the training set did you alter? How does that compare with the amount of data in a real system?

## Defending against poisoning {#defending-against-poisoning}

Poisoning is difficult to detect once data has been collected, as the attack leaves no error messages. A number of defences can reduce the risk:

* **Know your data's origin.** Control who can contribute to training data, and keep a record of where it came from.
* **Check labels.** A label that disagrees with the labels of very similar examples is suspicious, which can help to catch label flipping.
* **Look at how the model behaves on altered inputs.** Fine-pruning (Liu et al., 2018) removes parts of a network that stay inactive on clean data, which may be where a backdoor has lodged. Neural Cleanse (Wang et al., 2019) searches for a small pattern that pushes every input towards one class.
* **Test with more than ordinary test data,** bearing in mind that the defender doesn't know what the trigger is.

> Log Book Question: You are responsible for a model trained on data submitted by the public. Which of these defences would you apply, and which of your two attacks would each one help against?

## Conclusion {#conclusion}

At this point you have:

* trained a clean baseline model
* flipped labels so that a retrained model misread one digit as another
* planted a backdoor that forced a chosen answer whenever a trigger appeared
* measured clean accuracy and attack success rate
* repeated the attack using fewer poisoned examples
* considered how poisoning can be detected or prevented

> Tip: Well done!

In the next lab, you will attack a deployed model without changing its training at all, by carefully altering what you show it.

## References {#references}

Gu, T., Dolan-Gavitt, B. and Garg, S. (2017) 'BadNets: Identifying Vulnerabilities in the Machine Learning Model Supply Chain', *arXiv:1708.06733*.

Liu, K., Dolan-Gavitt, B. and Garg, S. (2018) 'Fine-Pruning: Defending Against Backdooring Attacks on Deep Neural Networks', *International Symposium on Research in Attacks, Intrusions, and Defenses*.

Wang, B. et al. (2019) 'Neural Cleanse: Identifying and Mitigating Backdoor Attacks in Neural Networks', *IEEE Symposium on Security and Privacy*.
