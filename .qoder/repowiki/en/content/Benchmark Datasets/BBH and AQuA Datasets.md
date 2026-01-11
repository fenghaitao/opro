# BBH and AQuA Datasets

<cite>
**Referenced Files in This Document**   
- [README.md](file://README.md)
- [data/README.md](file://data/README.md)
- [misc/prompt_history/README.md](file://misc/prompt_history/README.md)
- [opro/evaluation/evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py)
- [opro/optimization/optimize_instructions.py](file://opro/optimization/optimize_instructions.py)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py)
- [opro/prompt_utils.py](file://opro/prompt_utils.py)
- [misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt)
- [misc/prompt_history/BBH-causal_judgement-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-causal_judgement-s-text-bison-o-palm-2-l-it.txt)
- [misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Big-Bench Hard (BBH) Dataset](#big-bench-hard-bbh-dataset)
3. [AQuA Dataset](#aqua-dataset)
4. [Dataset Integration and Usage](#dataset-integration-and-usage)
5. [Licensing and Data Access](#licensing-and-data-access)
6. [Extending opro for BBH and AQuA](#extending-opro-for-bbh-and-aqua)

## Introduction
The opro repository implements a framework for using large language models as optimizers to improve prompt instructions for various benchmark datasets. This document provides comprehensive documentation for two key datasets referenced in the project: Big-Bench Hard (BBH) and AQuA (Automated Question Answering). These datasets are external to the repository but are crucial for evaluating the performance of prompt optimization techniques. The documentation covers their structure, sources, integration patterns, and usage within the opro evaluation framework, providing guidance for researchers and developers working with these benchmarks.

**Section sources**
- [README.md](file://README.md#L1-L79)

## Big-Bench Hard (BBH) Dataset

The Big-Bench Hard (BBH) dataset is a curated subset of the larger BIG-Bench suite, specifically selected to evaluate challenging reasoning tasks that are difficult for language models. BBH focuses on tasks that require complex logical reasoning, causal inference, and multi-step problem solving, making it a valuable benchmark for assessing the reasoning capabilities of advanced language models.

### BBH Role and Task Categories
BBH serves as a benchmark for evaluating language models on tasks that demand sophisticated reasoning skills beyond simple pattern recognition or factual recall. The dataset includes 23 distinct tasks that span various reasoning domains, including logical deduction, causal judgment, temporal reasoning, and multi-step arithmetic. These tasks are designed to be particularly challenging, with the original BIG-Bench paper noting that they represent the most difficult problems from the broader benchmark suite.

Key task categories in BBH include:
- **Logical Reasoning**: Tasks like "logical_deduction_seven_objects" and "formal_fallacies" that require understanding logical relationships and constraints
- **Causal Reasoning**: Tasks like "causal_judgement" that assess the ability to determine cause-and-effect relationships
- **Temporal Reasoning**: Tasks like "temporal_sequences" that require understanding chronological order and time-based relationships
- **Mathematical Reasoning**: Tasks like "multistep_arithmetic_two" and "object_counting" that involve numerical calculations and quantitative reasoning
- **Linguistic Reasoning**: Tasks like "dyck_languages" and "word_sorting" that test understanding of language structure and patterns

The BBH dataset is referenced in the opro repository through the `data/README.md` file, which indicates it is downloaded from the GitHub repository suzgunmirac/BIG-Bench-Hard. The evaluation scripts in the opro framework are specifically configured to handle BBH tasks, with support for all 23 individual tasks as defined in the `evaluate_instructions.py` script.

### BBH Data Structure and Schema
The BBH dataset is structured as a collection of JSON files, with each file corresponding to a specific task. The data format consists of input-output pairs where each example contains an "input" field with the question or prompt and a "target" field with the correct answer. The answers in BBH can be of different types depending on the task, including boolean values (True/False), multiple-choice selections (A/B/C/D), numerical values, or short text responses.

The schema for BBH data follows this structure:
```json
{
  "input": "Question or prompt text",
  "target": "Correct answer"
}
```

For example, in the "logical_deduction_seven_objects" task, the input might describe a set of objects with specific relationships, and the target would be the answer to a question about the logical arrangement of these objects. In the "causal_judgement" task, the input presents a scenario and asks whether one event caused another, with the target being "yes" or "no".

The opro framework loads BBH data through the `load_bbh_task_data` function in the evaluation utilities, which reads the JSON files and processes them into a format suitable for evaluation. The data is stored in a directory named "BIG-Bench-Hard-data" within the project's data folder, as specified in the evaluation script.

### BBH Usage Examples from Prompt History
The prompt history files in the misc directory provide concrete examples of how BBH tasks are used in practice within the opro framework. These files contain records of prompt optimization experiments, showing how different instructions were tested and refined to improve performance on specific BBH tasks.

For the "logical_deduction_seven_objects" task, the prompt history shows optimization of instructions like "The following paragraphs each describe a set of seven objects arranged in a fixed order. The statements are logically consistent within each paragraph. Use the information in the paragraph to answer the question that follows." This instruction guides the model to focus on the logical consistency of the statements and use them to deduce the correct answer.

For the "causal_judgement" task, the prompt history reveals optimization of instructions such as "How would a typical person answer each of the following questions about causation?" and "A typical person would answer the questions about causation by considering all the relevant factors and determining which ones are proximate, direct, or ultimate causes of the problem." These instructions aim to align the model's reasoning with human-like causal judgment.

The "boolean_expressions" task prompt history shows optimization of instructions that guide the model to evaluate logical expressions, with successful instructions including "True and (False or not not False) is True" and "False and not (False or True or not False) is False." These examples demonstrate how the optimization process refines instructions to improve accuracy on boolean logic evaluation.

**Section sources**
- [data/README.md](file://data/README.md#L16-L19)
- [opro/evaluation/evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L125-L171)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py#L571-L579)
- [misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt)
- [misc/prompt_history/BBH-causal_judgement-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-causal_judgement-s-text-bison-o-palm-2-l-it.txt)
- [misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt)

## AQuA Dataset

The AQuA (Automated Question Answering) dataset is designed to evaluate numerical reasoning and confidence calibration in language models. Unlike BBH, which focuses on logical and causal reasoning, AQuA emphasizes mathematical problem-solving abilities and the model's capacity to provide rationales for its answers.

### AQuA Format and Rationale Structure
AQuA presents multiple-choice questions that require numerical reasoning, with each question accompanied by a rationale that explains the step-by-step solution process. This format allows for evaluation not only of the final answer accuracy but also of the reasoning process that leads to the answer. The inclusion of rationales makes AQuA particularly valuable for assessing how well models can generate coherent and correct explanations for their solutions.

The dataset structure includes several key fields:
- **question**: The text of the multiple-choice question
- **options**: A list of possible answer choices, typically labeled A, B, C, D, and E
- **rationale**: A detailed explanation of how to solve the problem step by step
- **correct**: The correct answer choice (A, B, C, D, or E)

This format enables the evaluation of both the model's ability to select the correct answer and its capacity to generate a rationale that matches the provided explanation. The presence of rationales allows researchers to analyze whether models are arriving at correct answers through valid reasoning processes or through pattern matching without genuine understanding.

### AQuA Numerical Reasoning Assessment
AQuA is specifically designed to assess numerical reasoning capabilities, with questions that cover a range of mathematical concepts including arithmetic, algebra, probability, and basic statistics. The problems often require multiple steps of calculation and logical inference, making them challenging for language models that may struggle with maintaining numerical precision throughout a multi-step process.

The evaluation framework in opro handles AQuA as a multiple-choice task, with the `evaluate_instructions.py` script explicitly supporting the "aqua" dataset. When evaluating on AQuA, the framework treats all tasks as multiple-choice questions, as indicated by the code that sets `multiple_choice_tasks = set(tasks_all)` when the dataset is "aqua". This configuration ensures that the evaluation metrics properly account for the multiple-choice nature of the questions.

The assessment of numerical reasoning in AQuA goes beyond simple answer selection. The presence of rationales allows for evaluation of the model's confidence calibration—how well the model's confidence in its answers aligns with its actual accuracy. This is particularly important for applications where understanding the model's uncertainty is crucial, such as in educational or decision-support systems.

### AQuA Data Schema and Integration
The AQuA dataset is structured as a JSON Lines (JSONL) file, where each line contains a JSON object representing a single question with its associated metadata. This format is efficient for processing large datasets and allows for streaming access to individual examples without loading the entire dataset into memory.

The schema for AQuA data follows this structure:
```json
{
  "question": "Text of the question",
  "options": ["(A) Option 1", "(B) Option 2", "(C) Option 3", "(D) Option 4", "(E) Option 5"],
  "rationale": "Step-by-step explanation of the solution",
  "correct": "A"
}
```

In the opro framework, AQuA data is loaded using the `read_jsonl` function from the evaluation utilities, which reads the JSONL file and converts it into a list of dictionaries. The data is expected to be located in a directory named "AQuA-data" within the project's data folder, with the main data file named "AQuA.json". This structure is specified in the `evaluate_instructions.py` script, which sets the root data folder path for AQuA accordingly.

The integration of AQuA into the evaluation framework follows the same pattern as other datasets, with the `gen_prompt` function formatting the question and options appropriately for presentation to the language model. The evaluation process then compares the model's response to the correct answer and can optionally analyze the generated rationale against the provided one.

**Section sources**
- [data/README.md](file://data/README.md#L22-L24)
- [opro/evaluation/evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L130-L131)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py#L47-L51)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py#L153-L161)

## Dataset Integration and Usage

The opro framework provides a standardized interface for integrating and using external benchmark datasets like BBH and AQuA. This integration is implemented through the evaluation and optimization scripts, which handle dataset loading, configuration, and execution of evaluation workflows.

### Loading Mechanism and Configuration
The integration of BBH and AQuA datasets into the opro framework follows a consistent pattern across all supported benchmarks. The evaluation script `evaluate_instructions.py` serves as the primary entry point for dataset usage, with command-line arguments that specify the dataset, task, and other configuration parameters.

The loading mechanism is implemented through conditional logic that determines the appropriate data directory based on the specified dataset:
- For BBH: `root_data_folder_path = os.path.join(ROOT_DATA_FOLDER_PATH, "BIG-Bench-Hard-data/")`
- For AQuA: `root_data_folder_path = os.path.join(ROOT_DATA_FOLDER_PATH, "AQuA-data")`

This configuration ensures that the framework looks for dataset files in the correct locations within the project structure. The evaluation script validates the dataset and task names through assertions, preventing execution with unsupported configurations. For BBH, the script supports all 23 individual tasks, while for AQuA, it treats the entire dataset as a single task category.

The data loading process differs slightly between the two datasets due to their different file formats:
- BBH data is loaded using the `load_bbh_task_data` function, which reads JSON files for individual tasks
- AQuA data is loaded using the `read_jsonl` function, which processes the JSON Lines format of the AQuA dataset

Both loading functions return the data in a consistent format that can be processed by the evaluation framework, ensuring that the subsequent steps of prompt generation and result evaluation can proceed uniformly regardless of the source dataset.

### Command-Line Interface and Parameters
The opro framework provides a command-line interface for evaluating instructions on both BBH and AQuA datasets. The primary script for this purpose is `evaluate_instructions.py`, which accepts several parameters to configure the evaluation:

```bash
python evaluate_instructions.py \
    --scorer="text-bison" \
    --dataset="bbh" \
    --task="logical_deduction_seven_objects" \
    --instruction_pos="Q_begin" \
    --evaluate_training_fold=false \
    --evaluate_test_fold=true \
    --palm_api_key="<your_palm_api_key>"
```

Key parameters include:
- **scorer**: Specifies the language model to use for evaluation (e.g., "text-bison" or "gpt-3.5-turbo")
- **dataset**: Specifies the dataset to evaluate on ("bbh" or "aqua")
- **task**: For BBH, specifies the specific task; for AQuA, this is typically set to "self"
- **instruction_pos**: Determines where the instruction is placed in the prompt (before_Q, Q_begin, Q_end, or A_begin)
- **evaluate_training_fold** and **evaluate_test_fold**: Control whether to evaluate on training and test splits

The optimization script `optimize_instructions.py` provides a similar interface for prompt optimization:
```bash
python optimize_instructions.py \
    --optimizer="gpt-3.5-turbo" \
    --scorer="text-bison" \
    --instruction_pos="A_begin" \
    --dataset="bbh" \
    --task="logical_deduction_seven_objects" \
    --palm_api_key="<your_palm_api_key>" \
    --openai_api_key="<your_openai_api_key>"
```

These command-line interfaces allow researchers to easily configure and run evaluations on BBH and AQuA datasets, with the framework handling the underlying data loading and processing automatically.

### Evaluation Workflow and Metrics
The evaluation workflow for BBH and AQuA follows a standardized process that ensures consistent and reliable results. When executing the evaluation script, the framework performs the following steps:

1. **Configuration and Validation**: The script validates the provided parameters and ensures that the specified dataset and task are supported
2. **Data Loading**: The appropriate dataset is loaded from the specified directory using the relevant loading function
3. **Prompt Generation**: Instructions are incorporated into prompts according to the specified position (before_Q, Q_begin, Q_end, or A_begin)
4. **Model Querying**: The scorer model is queried with the generated prompts to obtain responses
5. **Result Processing**: Responses are parsed and compared to the correct answers to calculate accuracy
6. **Output Generation**: Results are saved to output files with detailed metrics

The evaluation metrics differ slightly between BBH and AQuA due to their different task structures:
- For BBH: Accuracy is calculated based on the specific task type (boolean, multiple-choice, or numerical)
- For AQuA: Accuracy is calculated as the percentage of correctly answered multiple-choice questions

The framework also supports more detailed analysis through the generation of intermediate results, including raw prompts, model responses, and parsed answers. These are saved to output files that can be used for further analysis of model performance and behavior.

**Section sources**
- [opro/evaluation/evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L69-L177)
- [opro/optimization/optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L75-L158)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py#L164-L260)

## Licensing and Data Access

The BBH and AQuA datasets used in the opro framework are external resources with their own licensing terms and access requirements. Understanding these aspects is crucial for proper usage and compliance with legal and ethical guidelines.

### Dataset Sources and Licenses
The BBH dataset is derived from the BIG-Bench suite and is available through the GitHub repository suzgunmirac/BIG-Bench-Hard. As a derivative work of BIG-Bench, BBH inherits the licensing terms of the original dataset. The data/README.md file in the opro repository notes that "All copyrights belong to the original benchmark authors," indicating that users must respect the intellectual property rights of the dataset creators.

The AQuA dataset is available through the GitHub repository google-deepmind/AQuA. As a Google DeepMind project, AQuA is likely released under an open-source license, but users should verify the specific terms in the repository. The opro documentation acknowledges the original authors and sources, maintaining proper attribution for both datasets.

Both datasets are referenced in the opro repository but are not included directly in the codebase. This approach respects the licensing terms of the datasets while providing clear documentation of their sources and usage. Users are expected to download the datasets separately from their original sources and place them in the appropriate directories within the opro project structure.

### Data Access Procedures
Accessing the BBH and AQuA datasets requires downloading them from their respective GitHub repositories and organizing them according to the expected directory structure in the opro framework.

For BBH:
1. Download the dataset from https://github.com/suzgunmirac/BIG-Bench-Hard
2. Place the data files in a directory named "BIG-Bench-Hard-data" within the project's data folder
3. Ensure the JSON files for each task are properly organized

For AQuA:
1. Download the dataset from https://github.com/google-deepmind/AQuA
2. Place the data files in a directory named "AQuA-data" within the project's data folder
3. Ensure the main data file is named "AQuA.json" in JSON Lines format

The evaluation scripts in opro are configured to look for these specific directory and file names, so proper organization is essential for successful integration. The framework does not provide automated download functionality, requiring users to manually obtain and configure the datasets.

### Preprocessing Requirements
Before using the BBH and AQuA datasets with the opro framework, some preprocessing may be necessary to ensure compatibility with the evaluation scripts.

For BBH:
- Verify that the JSON files are properly formatted with "input" and "target" fields
- Ensure all 23 task files are present and correctly named
- Confirm that the directory structure matches the expected "BIG-Bench-Hard-data" path

For AQuA:
- Convert the dataset to JSON Lines format if necessary
- Ensure the file is named "AQuA.json" and placed in the "AQuA-data" directory
- Verify that each line contains a complete JSON object with "question", "options", "rationale", and "correct" fields

The opro framework includes utility functions to handle some aspects of data processing, such as the `read_jsonl` function for AQuA and the `load_bbh_task_data` function for BBH. However, users are responsible for ensuring the initial data is in the correct format and location before running the evaluation scripts.

**Section sources**
- [data/README.md](file://data/README.md#L18-L25)
- [README.md](file://README.md#L76-L78)

## Extending opro for BBH and AQuA

The opro framework is designed to be extensible, allowing researchers to add support for new datasets or modify existing functionality for BBH and AQuA. This section provides guidance on how to extend the framework to support these benchmarks with proper configuration.

### Configuration for New Tasks
To add support for new tasks within the BBH or AQuA datasets, developers can modify the configuration in the evaluation and optimization scripts. The primary entry point for configuration is the validation logic in `evaluate_instructions.py`, which defines the supported datasets and tasks.

For BBH, new tasks can be added by extending the assertion block that validates the task name:
```python
elif dataset_name == "bbh":
    assert task_name in {
        "boolean_expressions",
        "causal_judgement",
        # ... existing tasks
        "new_task_name",  # Add new task here
    }
```

For AQuA, since it is treated as a single task category, extensions would typically involve modifying how the data is processed rather than adding new task names. Developers can customize the prompt formatting, evaluation metrics, or data loading process to better suit specific research needs.

### Customizing Evaluation Parameters
The evaluation framework provides several parameters that can be customized to tailor the assessment of BBH and AQuA performance. These include:
- **Instruction position**: Control where the instruction is placed in the prompt (before_Q, Q_begin, Q_end, or A_begin)
- **Evaluation splits**: Configure the ratio of training and test data to evaluate on
- **Scoring model**: Select different language models for evaluation (text-bison, gpt-3.5-turbo, gpt-4)
- **Batch size and decoding parameters**: Adjust model serving configurations for performance optimization

These parameters can be modified through command-line arguments or by editing the default values in the evaluation script. For example, researchers might want to evaluate instructions at different positions in the prompt to determine which placement yields the best performance on BBH logical deduction tasks.

### Advanced Integration Patterns
For more advanced use cases, developers can extend the opro framework by implementing custom evaluation logic or integrating additional analysis tools. This might include:
- **Custom metrics**: Implementing new evaluation metrics beyond simple accuracy, such as F1 score, BLEU score for rationales, or confidence calibration measures
- **Ensemble methods**: Evaluating multiple models or instruction variants simultaneously and combining their outputs
- **Error analysis**: Adding functionality to automatically categorize and analyze model errors on specific task types
- **Visualization tools**: Integrating with visualization libraries to create charts and graphs of performance across different tasks and configurations

These extensions can be implemented by modifying the core evaluation functions in `eval_utils.py` or by creating new modules that integrate with the existing framework. The modular design of opro facilitates such extensions while maintaining compatibility with the core functionality.

**Section sources**
- [opro/evaluation/evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L125-L177)
- [opro/evaluation/eval_utils.py](file://opro/evaluation/eval_utils.py#L164-L260)
- [opro/prompt_utils.py](file://opro/prompt_utils.py#L21-L133)