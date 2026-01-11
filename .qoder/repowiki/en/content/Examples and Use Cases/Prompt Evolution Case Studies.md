# Prompt Evolution Case Studies

<cite>
**Referenced Files in This Document**   
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt)
- [BBH-object_counting-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-object_counting-s-text-bison-o-palm-2-l-it.txt)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py)
- [opt_utils.py](file://opro/optimization/opt_utils.py)
- [prompt_utils.py](file://opro/prompt_utils.py)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Understanding the Prompt Optimization System](#understanding-the-prompt-optimization-system)
3. [Interpreting Prompt History Files](#interpreting-prompt-history-files)
4. [Case Study: Boolean Expressions](#case-study-boolean-expressions)
5. [Case Study: Object Counting](#case-study-object-counting)
6. [Meta-Prompt Structure and Optimization Strategies](#meta-prompt-structure-and-optimization-strategies)
7. [Patterns of Successful Optimization](#patterns-of-successful-optimization)
8. [When Optimization Plateaus](#when-optimization-plateaus)
9. [Conclusion](#conclusion)

## Introduction

This document presents a detailed analysis of prompt evolution trajectories from the `misc/prompt_history/` directory. By examining specific optimization runs such as BBH-boolean_expressions and BBH-object_counting, we illustrate how instructions improved across iterations. The analysis breaks down the meta-prompt structure used to guide the optimizer LLM and shows concrete examples of instruction revisions that led to measurable performance gains. We highlight patterns in successful optimizations, such as increased specificity, better chain-of-thought prompting, and decomposition of complex tasks. Side-by-side comparisons of early vs. final prompts demonstrate the system's effectiveness. The document also explains how to interpret the .txt files, including understanding the scoring mechanism and identifying high-impact changes. Insights into when optimization plateaus occur and how to restart the process with new meta-strategies are provided. These case studies are connected to broader prompt engineering principles applicable beyond the provided benchmarks.

## Understanding the Prompt Optimization System

The prompt optimization system is designed to iteratively improve instructions for large language models (LLMs) by leveraging an optimizer LLM to generate new instructions based on the performance of previous instructions. The system is implemented in the `optimize_instructions.py` file, which orchestrates the optimization process by configuring the scorer and optimizer LLMs, reading the dataset, and running the evolution loop.

The optimization process begins with initial instructions, which are evaluated on a training set to establish a baseline performance. The optimizer LLM is then prompted with a meta-prompt that includes the history of previous instructions and their scores, along with a few-shot exemplars from the dataset. The meta-prompt guides the optimizer to generate new instructions that are different from the previous ones and have a higher score. The generated instructions are evaluated on the training set, and the process repeats for a specified number of steps.

The system supports different types of meta-prompts, including those with both previous instructions and dataset exemplars, or only previous instructions. The choice of meta-prompt type depends on whether the optimizer LLM is fine-tuned or pre-trained. The system also allows for different strategies for selecting the few-shot exemplars, such as random selection, selection based on the most frequent wrong answers, or selection based on the current most frequent wrong answers.

The optimization process is configured through command-line arguments, which specify the scorer and optimizer LLMs, the dataset and task, the position of the instruction in the prompt, and other hyperparameters. The system is designed to be flexible and can be adapted to different datasets and tasks by modifying the configuration.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)

## Interpreting Prompt History Files

The prompt history files in the `misc/prompt_history/` directory contain the evolution of instructions for specific tasks. Each file is named according to the task, scorer, optimizer, and other parameters, following the pattern `BBH-{task}-s-{scorer}-o-{optimizer}-l-it.txt`. For example, `BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt` contains the prompt evolution for the boolean expressions task using the text-bison scorer and the palm-2 optimizer.

Each line in the prompt history file represents a step in the optimization process and includes the step number, the training accuracy, and the instruction. The step number indicates the iteration of the optimization process, with step -1 representing the initial instruction and subsequent steps representing the instructions generated by the optimizer LLM. The training accuracy is the average score of the instruction on the training set, which is used to evaluate the performance of the instruction.

The instruction is the text that is inserted into the prompt at the specified position, which can be before the question, at the beginning of the question, at the end of the question, or at the beginning of the answer. The instruction is designed to guide the scorer LLM in solving the task, and the optimization process aims to find instructions that maximize the training accuracy.

By analyzing the prompt history files, we can observe how the instructions evolve over time and identify patterns of successful optimization. For example, we can see how the instructions become more specific, how they incorporate chain-of-thought reasoning, or how they decompose complex tasks into simpler subtasks.

**Section sources**
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt#L1-L1435)
- [BBH-object_counting-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-object_counting-s-text-bison-o-palm-2-l-it.txt#L1-L1595)

## Case Study: Boolean Expressions

The boolean expressions task involves evaluating logical expressions that combine logical variables, operators, and parentheses. The goal is to determine the truth value of the expression based on the values of the variables and the operators. The prompt history file `BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt` contains the evolution of instructions for this task.

The initial instruction at step -1 has a training accuracy of 0.800, which serves as the baseline performance. The first instruction generated by the optimizer LLM at step 0 is "False and False or not (True) is False", which has a training accuracy of 0.880, representing an improvement over the baseline. This instruction is a specific example of a logical expression and its evaluation, which may help the scorer LLM understand the task.

As the optimization process progresses, the instructions become more varied and complex. For example, at step 1, the instruction "Not False" has a training accuracy of 0.680, while the instruction "True or False or (True and False)" has a training accuracy of 0.660. These instructions are simpler and may not provide enough context for the scorer LLM to understand the task.

At step 2, the instruction "False and True and ( not False ) is False" has a training accuracy of 0.860, which is an improvement over the previous steps. This instruction is similar to the initial instruction but with different values for the variables, which may help the scorer LLM generalize to different inputs.

The optimization process continues with the generation of new instructions at each step, and the training accuracy fluctuates between 0.460 and 0.920. The highest training accuracy of 0.920 is achieved at step 22 with the instruction "True and False and not (True or False or True) is False", which is a complex logical expression that combines multiple operators and parentheses.

The evolution of instructions for the boolean expressions task demonstrates the effectiveness of the optimization process in finding instructions that improve the performance of the scorer LLM. The instructions become more specific and complex over time, and the training accuracy improves as a result.

**Section sources**
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt#L1-L1435)

## Case Study: Object Counting

The object counting task involves counting the number of items in a list. The goal is to determine the total number of objects based on the description of the list. The prompt history file `BBH-object_counting-s-text-bison-o-palm-2-l-it.txt` contains the evolution of instructions for this task.

The initial instruction at step -1 has a training accuracy of 0.500, which serves as the baseline performance. The first instruction generated by the optimizer LLM at step 0 is "Count the number of items in the list.", which has a training accuracy of 0.540, representing a slight improvement over the baseline. This instruction is a direct command to count the items, which may help the scorer LLM understand the task.

As the optimization process progresses, the instructions become more detailed and specific. For example, at step 1, the instruction "How many items are there in the following list?" has a training accuracy of 0.460, while the instruction "I will count the number of objects in the list. Let me know if the number is correct." has a training accuracy of 0.500. These instructions are more conversational and may help the scorer LLM engage with the task.

At step 2, the instruction "I will count the number of items in your list. Please let me know if I have missed any item." has a training accuracy of 0.600, which is a significant improvement over the previous steps. This instruction is more interactive and invites feedback from the user, which may help the scorer LLM improve its performance.

The optimization process continues with the generation of new instructions at each step, and the training accuracy fluctuates between 0.140 and 0.700. The highest training accuracy of 0.700 is achieved at step 23 with the instruction "How many items do you have? Please list them one by one, and separate each item with a comma. I will then tell you how many items you have.", which is a detailed and specific instruction that guides the user on how to provide the input.

The evolution of instructions for the object counting task demonstrates the effectiveness of the optimization process in finding instructions that improve the performance of the scorer LLM. The instructions become more detailed and specific over time, and the training accuracy improves as a result.

**Section sources**
- [BBH-object_counting-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-object_counting-s-text-bison-o-palm-2-l-it.txt#L1-L1595)

## Meta-Prompt Structure and Optimization Strategies

The meta-prompt is a critical component of the prompt optimization system, as it guides the optimizer LLM in generating new instructions. The structure of the meta-prompt is defined in the `gen_meta_prompt` function in the `opt_utils.py` file, which takes as input the history of previous instructions and their scores, the position of the instruction in the prompt, the optimizer LLM name, and other parameters.

The meta-prompt includes two main parts: the old instruction part and the exemplar part. The old instruction part contains the history of previous instructions and their scores, which are used to inform the optimizer LLM about the performance of previous instructions. The exemplar part contains a few-shot exemplars from the dataset, which are used to provide context for the task and guide the optimizer LLM in generating new instructions.

The old instruction part is formatted as a list of instructions and their scores, with the instructions enclosed in `<INS>` and `</INS>` tags for GPT models or in square brackets for text-bison models. The scores are bucketized into a specified number of buckets to reduce the precision and prevent the optimizer LLM from overfitting to the scores. The old instruction part is sorted by score, with the highest-scoring instructions appearing first.

The exemplar part is formatted as a list of input-output pairs from the dataset, with the instruction position marked by `<INS>` for text-bison models or by `<Start>` and `</Start>` for GPT models. The input is the question or problem, and the output is the ground truth answer. The exemplar part is designed to show the optimizer LLM how to apply the instruction to solve the task.

The meta-prompt also includes a final instruction that guides the optimizer LLM in generating new instructions. For GPT models, the final instruction is to generate an instruction that is different from all the previous instructions and has a higher score. For text-bison models, the final instruction is to write a new text that is different from the old ones and has a score as high as possible.

The optimization strategies are determined by the parameters of the optimization process, such as the few-shot selection criteria, the number of few-shot questions for instruction refinement, and the evaluation interval. The few-shot selection criteria can be random, constant, accumulative most frequent, or current most frequent, which determines how the few-shot exemplars are selected from the training set. The number of few-shot questions for instruction refinement determines the number of exemplars included in the meta-prompt. The evaluation interval determines how often the instructions are evaluated on the validation set.

The meta-prompt structure and optimization strategies are designed to balance exploration and exploitation, encouraging the optimizer LLM to generate diverse instructions while focusing on those that are likely to improve performance. The system is flexible and can be adapted to different tasks and datasets by modifying the parameters and the meta-prompt structure.

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L200-L999)
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L133)

## Patterns of Successful Optimization

The analysis of the prompt evolution trajectories reveals several patterns of successful optimization that can be applied to other tasks and datasets. These patterns include increased specificity, better chain-of-thought prompting, and decomposition of complex tasks.

Increased specificity refers to the tendency of the instructions to become more detailed and specific over time. For example, in the object counting task, the initial instruction "Count the number of items in the list." is replaced by more specific instructions such as "Please list your items one by one, separated by commas. I will count them and tell you how many there are." This increased specificity helps the scorer LLM understand the task and provides clear guidance on how to solve it.

Better chain-of-thought prompting refers to the use of instructions that guide the scorer LLM through a step-by-step reasoning process. For example, in the boolean expressions task, the instruction "True and False and not (True or False or True) is False" implicitly guides the scorer LLM to evaluate the expression in a specific order, which may help it arrive at the correct answer. This type of instruction encourages the scorer LLM to think through the problem systematically, which can improve its performance.

Decomposition of complex tasks refers to the breaking down of a complex task into simpler subtasks. For example, in the object counting task, the instruction "Please list the items you have, one by one, separated by commas. I will then count them and tell you how many there are." decomposes the task into two subtasks: listing the items and counting them. This decomposition helps the scorer LLM focus on one aspect of the task at a time, which can improve its accuracy.

These patterns of successful optimization are not mutually exclusive and can be combined in a single instruction. For example, an instruction that is both specific and uses chain-of-thought prompting can be more effective than one that only has one of these characteristics. The optimization process is designed to find instructions that combine these patterns in a way that maximizes performance.

The patterns of successful optimization are also influenced by the meta-prompt structure and the optimization strategies. For example, the use of few-shot exemplars in the meta-prompt can encourage the optimizer LLM to generate instructions that are similar to those that performed well in the past. The choice of few-shot selection criteria can also influence the patterns of optimization, with random selection encouraging exploration and accumulative most frequent selection encouraging exploitation.

By understanding these patterns of successful optimization, we can apply them to other tasks and datasets to improve the performance of LLMs. The prompt optimization system provides a framework for systematically exploring these patterns and finding the best instructions for a given task.

**Section sources**
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt#L1-L1435)
- [BBH-object_counting-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-object_counting-s-text-bison-o-palm-2-l-it.txt#L1-L1595)

## When Optimization Plateaus

Optimization plateaus occur when the performance of the instructions stops improving, despite the generation of new instructions. This can happen for several reasons, such as the optimizer LLM reaching the limits of its capabilities, the meta-prompt structure becoming stale, or the few-shot exemplars no longer being representative of the task.

One indicator of an optimization plateau is a lack of improvement in the training accuracy over several steps. For example, in the boolean expressions task, the training accuracy fluctuates between 0.460 and 0.920, with no clear trend of improvement. This suggests that the optimizer LLM is generating instructions that are not consistently better than the previous ones.

Another indicator of an optimization plateau is the repetition of similar instructions. For example, in the object counting task, the instruction "Please list your items one by one, separated by commas. I will count them and tell you how many there are." appears multiple times with slight variations. This suggests that the optimizer LLM is stuck in a local optimum and is not exploring new areas of the instruction space.

To overcome an optimization plateau, several strategies can be employed. One strategy is to restart the optimization process with new initial instructions. This can help the optimizer LLM escape from a local optimum and explore new areas of the instruction space. Another strategy is to modify the meta-prompt structure, such as by changing the few-shot selection criteria or the number of few-shot questions for instruction refinement. This can provide new context for the task and guide the optimizer LLM in generating different instructions.

A third strategy is to introduce new meta-strategies, such as using a different optimizer LLM or changing the position of the instruction in the prompt. This can provide a fresh perspective on the task and help the optimizer LLM find new ways to improve performance. For example, in the object counting task, changing the instruction position from the beginning of the question to the end of the question may encourage the optimizer LLM to generate instructions that are more focused on the output.

Finally, it is important to monitor the performance of the instructions on a validation set to ensure that the improvements on the training set are not due to overfitting. If the performance on the validation set plateaus while the performance on the training set continues to improve, this may indicate that the instructions are overfitting to the training set and are not generalizing to new inputs.

By recognizing the signs of an optimization plateau and employing strategies to overcome it, we can continue to improve the performance of LLMs and find the best instructions for a given task.

**Section sources**
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt#L1-L1435)
- [BBH-object_counting-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-object_counting-s-text-bison-o-palm-2-l-it.txt#L1-L1595)

## Conclusion

The prompt evolution case studies presented in this document demonstrate the effectiveness of the prompt optimization system in improving the performance of LLMs on specific tasks. By analyzing the evolution of instructions for the boolean expressions and object counting tasks, we have identified patterns of successful optimization, such as increased specificity, better chain-of-thought prompting, and decomposition of complex tasks. These patterns can be applied to other tasks and datasets to improve the performance of LLMs.

The meta-prompt structure and optimization strategies play a critical role in guiding the optimizer LLM in generating new instructions. By carefully designing the meta-prompt and selecting the optimization strategies, we can balance exploration and exploitation and find the best instructions for a given task. However, optimization plateaus can occur when the performance of the instructions stops improving, and strategies such as restarting the optimization process, modifying the meta-prompt structure, or introducing new meta-strategies can be employed to overcome them.

The prompt optimization system provides a powerful framework for systematically exploring the space of possible instructions and finding those that maximize performance. By understanding the patterns of successful optimization and the factors that influence them, we can apply these principles to a wide range of tasks and datasets and continue to improve the capabilities of LLMs.