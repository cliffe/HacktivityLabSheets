{%- comment -%}
Shared "Meet Hackerbot!" section for Hackerbot labs. Single point of maintenance:
edit this file rather than the copy in each lab sheet.

Parameters:
  role - the clause after "a chatbot who will". Default: "attack your system".
         e.g. role="task you to monitor the network and will attack your systems"
  chat - "full"  : list of opening messages to try (first Hackerbot lab in a series)
         "hello" : just send "hello"
         omitted : no chat step (later labs, where students already know)
{%- endcomment -%}
## Meet Hackerbot! {#meet-hackerbot}

![Skull and USB stick]({{ site.baseurl }}/assets/images/shared/skullandusb.svg){: .hackerbot-avatar}

This exercise involves interacting with Hackerbot, a chatbot who will {{ include.role | default: "attack your system" }}. If you satisfy Hackerbot by completing the challenges, she will reveal flags to you.
{% if include.chat == "full" %}
==VM: On the desktop VM==, ==action: open Firefox and go to `hackerbot:8080`, then send some messages to Hackerbot:==

- Try asking Hackerbot some questions
- Send "help"
- Send "list"
- Send "hello"
{% elsif include.chat == "hello" %}
==VM: On the desktop VM==, ==action: open Firefox and go to `hackerbot:8080`, then send "hello" to Hackerbot:==
{% endif %}
> Tip: You can say **goto *N*** to Hackerbot to skip straight to a given attack number, or **next**/**previous** to move along one attack at a time.

Work through the below exercises, completing the Hackerbot challenges as noted.

---
