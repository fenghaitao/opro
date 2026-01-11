# Numerical Datasets Handling

<cite>
**Referenced Files in This Document**   
- [data\README.md](file://data/README.md)
- [data\MultiArith-data\MultiArith.json](file://data/MultiArith-data/MultiArith.json)
- [data\gsm_data\gsm_test.tsv](file://data/gsm_data/gsm_test.tsv)
- [data\AQuA-data\AQuA.json](file://data/AQuA-data/AQuA.json)
- [opro\evaluation\metrics.py](file://opro/evaluation/metrics.py)
- [opro\evaluation\eval_utils.py](file://opro/evaluation/eval_utils.py)
- [opro\evaluation\evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Dataset Overview](#dataset-overview)
3. [Data Loading and Parsing](#data-loading-and-parsing)
4. [Numerical Answer Processing](#numerical-answer-processing)
5. [Evaluation Workflow](#evaluation-workflow)
6. [Configuration and Extension](#configuration-and-extension)
7. [Conclusion](#conclusion)

## Introduction
This document provides comprehensive documentation for handling numerical datasets in the prompt evaluation system, focusing on GSM8K, MultiArith, and AQuA datasets. The system is designed to evaluate mathematical reasoning tasks by processing numerical answers through specialized parsing and comparison mechanisms. The core functionality revolves around the `get_normalized_prediction` function in the metrics module, which handles number parsing, decimal precision, and answer normalization. The evaluation workflow involves loading dataset-specific formats, processing model predictions, and comparing them against ground truth answers using exact match scoring. This documentation covers the implementation details, data handling procedures, and configuration options for numerical evaluation in the system.

## Dataset Overview
The prompt evaluation system supports three primary numerical reasoning datasets: GSM8K, MultiArith, and AQuA. Each dataset serves as a benchmark for evaluating mathematical problem-solving capabilities and has distinct characteristics in terms of format, content, and evaluation requirements.

The GSM8K dataset contains grade school math problems that require multi-step reasoning to solve. These problems typically involve arithmetic operations, percentages, and real-world scenarios that test basic mathematical skills. The dataset is stored in TSV format with three columns: the problem question, the correct numerical answer, and the step-by-step rationale. GSM8K focuses on problems that can be solved through a series of logical steps, making it suitable for evaluating chain-of-thought reasoning approaches.

The MultiArith dataset consists of multi-step arithmetic problems that require the model to perform several calculations in sequence. Unlike GSM8K, MultiArith problems are structured with explicit equations and solutions, making them particularly useful for testing the model's ability to follow mathematical procedures. The dataset is stored in JSON format with each entry containing an index, alignments, equations, solutions, and the problem question. The solutions are provided as floating-point numbers, emphasizing the need for precise numerical comparison.

The AQuA dataset features quantitative aptitude questions that often involve algebra, geometry, and logical reasoning. These problems are multiple-choice in nature, with each entry containing a question, multiple options, a rationale, and the correct answer identifier. AQuA problems typically require more abstract mathematical thinking and are designed to test higher-level reasoning skills. The dataset is stored in JSONL format, with each line representing a separate JSON object containing all the problem information.

These datasets collectively provide a comprehensive testbed for evaluating numerical reasoning capabilities across different mathematical domains and complexity levels. The system processes each dataset according to its specific format while maintaining a consistent evaluation methodology for numerical answers.

**Section sources**
- [data\README.md](file://data/README.md#L5-L24)
- [data\MultiArith-data\MultiArith.json](file://data/MultiArith-data/MultiArith.json#L1-L800)
- [data\gsm_data\gsm_test.tsv](file://data/gsm_data/gsm_test.tsv#L1-L184)
- [data\AQuA-data\AQuA.json](file://data/AQuA-data/AQuA.json#L1-L192)

## Data Loading and Parsing
The system implements dataset-specific data loading and parsing mechanisms to handle the different formats of GSM8K, MultiArith, and AQuA datasets. Each dataset requires a unique approach to extract questions, answers, and relevant metadata for evaluation.

For the AQuA dataset, which is stored in JSONL format, the system uses the `read_jsonl` function defined in `eval_utils.py`. This function reads the JSONL file line by line, parsing each line as a separate JSON object. The implementation is straightforward, opening the file in UTF-8 encoding and converting each non-empty line to a Python dictionary using `json.loads`. This approach efficiently handles the streaming nature of JSONL files, allowing for memory-efficient processing of large datasets. The parsed data structure contains the question, options, rationale, and correct answer for each problem, which are then used in the evaluation process.

The MultiArith dataset, stored in a single JSON file, is loaded using Python's built-in `json` module. The system reads the entire file and parses it as a JSON array, where each element represents a problem instance. The data structure includes the problem index, alignments, equations, solutions, and the question text. The solutions are stored as floating-point numbers in a list, with the first (and typically only) element being the correct numerical answer. This format allows for direct access to the numerical solution without additional parsing, making it efficient for numerical comparison during evaluation.

The GSM8K dataset uses TSV (Tab-Separated Values) format, which is loaded using pandas' `read_csv` function with a tab separator. The TSV file contains three columns: the problem question, the correct answer, and the step-by-step rationale. The system extracts the question and answer directly from the appropriate columns, treating the answer as a string for initial processing. This format is particularly suitable for automated processing, as the tabular structure ensures consistent alignment of data fields across all problem instances.

The evaluation system determines the appropriate loading method based on the dataset name parameter. When initializing the evaluation process, the system checks the dataset name and selects the corresponding data loading function. For AQuA, it calls `read_jsonl`; for MultiArith, it uses direct JSON loading; and for GSM8K, it employs pandas' CSV reader with a tab separator. This modular approach allows the system to handle multiple dataset formats while maintaining a consistent interface for the evaluation pipeline.

**Section sources**
- [opro\evaluation\eval_utils.py](file://opro/evaluation/eval_utils.py#L47-L51)
- [opro\evaluation\evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L584-L588)
- [data\gsm_data\gsm_test.tsv](file://data/gsm_data/gsm_test.tsv#L1-L184)
- [data\MultiArith-data\MultiArith.json](file://data/MultiArith-data/MultiArith.json#L1-L800)
- [data\AQuA-data\AQuA.json](file://data/AQuA-data/AQuA.json#L1-L192)

## Numerical Answer Processing
The core of numerical answer processing in the system is the `get_normalized_prediction` function in the `metrics.py` module. This function is responsible for parsing and normalizing model predictions to enable accurate comparison with ground truth answers. The normalization process involves several steps to handle various formats and representations of numerical answers that models might produce.

The function first converts the prediction to lowercase and strips whitespace. It then identifies whether the answer appears after specific patterns like "answer is ", "answer: ", or before patterns like " is the correct answer". If such patterns are found, the function extracts the portion of the text that contains the actual answer. This mechanism allows the system to locate the final answer even when the model generates extensive reasoning text before or after it.

For numerical answers, the function performs extensive preprocessing to handle different representations. It removes currency symbols ($, €, £), commas, and percentage signs from the prediction text. The function also converts word numbers (like "twenty") to their numerical equivalents using a predefined mapping. This capability ensures that answers expressed in words are correctly interpreted and compared with numerical ground truth values.

The normalization process includes sophisticated token extraction to identify the relevant numerical portion of the prediction. If the answer indicator pattern is present, the function takes the first token with numerical values; otherwise, it takes the last such token. This approach accommodates different answer formatting conventions while maintaining consistency in extraction. The function also handles units by removing alphabetic characters from the end of the prediction, allowing it to extract pure numerical values from expressions like "5600 pounds".

For decimal precision handling, the function rounds the parsed number to the same number of decimal places as the target answer. This ensures that comparisons are made at the appropriate precision level, preventing false negatives due to insignificant decimal differences. The system determines the required precision by examining the ground truth answer and counting the digits after the decimal point.

The `get_normalized_target_and_prediction` function orchestrates the normalization process by first normalizing the target answer to determine whether it should be treated as a number and what precision to use. It then applies the same normalization parameters to the prediction, ensuring consistent treatment of both values. This approach guarantees that the comparison is fair and accurate, regardless of how the model chooses to format its output.

**Section sources**
- [opro\evaluation\metrics.py](file://opro/evaluation/metrics.py#L188-L342)
- [opro\evaluation\metrics.py](file://opro/evaluation/metrics.py#L366-L441)

## Evaluation Workflow
The evaluation workflow for mathematical reasoning tasks follows a systematic process that begins with prompt generation and ends with accuracy calculation. The workflow is implemented in the `evaluate_single_instruction` function in `eval_utils.py` and is designed to handle numerical evaluation tasks efficiently and accurately.

The process begins with prompt generation using the `gen_prompt` function, which constructs input prompts by combining the dataset example with the instruction to be evaluated. The function supports different instruction positions (before the question, at the beginning of the question, at the end of the question, or at the beginning of the answer) and can include or exclude "Q:" and "A:" formatting based on the dataset requirements. For numerical datasets like GSM8K and MultiArith, the function extracts the question text and formats it according to the specified template.

Once the prompts are generated, the system sends them to the language model for processing. The responses are collected and then passed through the answer extraction pipeline. For some models, the system may perform a second round of prompting to better extract the final answer by appending "So the final answer is" to the original prompt and model response. This technique improves answer extraction when the model's initial response does not clearly indicate the final answer.

The extracted answers are then processed through the normalization pipeline using `get_normalized_prediction`. This function applies the preprocessing steps described in the previous section to convert the raw model output into a standardized numerical format. The normalization parameters (treat_as_number, num_decimals) are determined based on the ground truth answer, ensuring that the prediction is processed with the same criteria.

The final step in the evaluation workflow is accuracy calculation using the `number_included_accuracy_list` function. For numerical answers, the system compares the normalized prediction with the normalized target using numerical comparison rather than exact string matching. The function attempts to convert both values to floating-point numbers and checks if their absolute difference is within a small epsilon value (1e-5), accounting for potential floating-point precision issues.

The evaluation results are compiled into a detailed DataFrame containing the raw prompt, raw answer, parsed answer, true answer, and accuracy score for each example. This comprehensive output allows for detailed analysis of model performance, including identification of specific problem types where the model excels or struggles. The system also calculates overall accuracy metrics that summarize the model's performance across the evaluation set.

**Section sources**
- [opro\evaluation\eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L800)
- [opro\evaluation\metrics.py](file://opro/evaluation/metrics.py#L443-L496)

## Configuration and Extension
The system provides flexible configuration options for numerical evaluation parameters and supports extension to additional numerical reasoning benchmarks. These capabilities are primarily controlled through the `evaluate_instructions.py` script, which serves as the main entry point for running evaluations.

The configuration parameters are exposed as command-line flags, allowing users to customize the evaluation process without modifying code. Key parameters include the scorer model (text-bison, gpt-3.5-turbo, or gpt-4), the dataset to evaluate (gsm8k, multiarith, aqua, mmlu, or bbh), the task within the dataset, and the position of the instruction in the prompt. Users can also specify whether to evaluate the training fold, test fold, or both, and set the ratios for train-test splits.

For numerical evaluation specifically, the system automatically configures the prediction processing parameters based on the dataset. When evaluating GSM8K or MultiArith, the system sets `prediction_treat_as_number=True` to ensure numerical comparison, while for AQuA it uses multiple-choice evaluation. The decimal precision is automatically determined from the target answer, eliminating the need for manual configuration of precision levels.

To extend the system to support additional numerical reasoning benchmarks, developers can follow the existing pattern of dataset integration. The process involves implementing a data loading function similar to `read_jsonl` for the new format, adding dataset-specific parsing logic to `gen_prompt` and `fetch_true_answer`, and updating the configuration validation in `evaluate_instructions.py`. The modular design of the evaluation pipeline makes it relatively straightforward to add support for new datasets while reusing the core evaluation and normalization components.

The system also supports parallel evaluation through multithreading, which can be enabled by setting `evaluate_in_parallel=True`. This feature significantly reduces evaluation time for large datasets by distributing prompts across multiple server instances. The batch size and number of servers can be configured to optimize performance based on available resources.

For custom evaluation scenarios, users can modify the instructions to evaluate by editing the `instructions_to_evaluate` list in `evaluate_instructions.py`. This list contains the prompts that will be tested, allowing for rapid experimentation with different instruction formats and strategies. The results are saved to timestamped directories for easy comparison across different evaluation runs.

**Section sources**
- [opro\evaluation\evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L63-L770)
- [opro\evaluation\eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L800)

## Conclusion
The numerical dataset handling system provides a robust framework for evaluating mathematical reasoning capabilities across multiple benchmarks. By implementing specialized data loading, answer normalization, and evaluation workflows, the system ensures accurate and consistent assessment of model performance on numerical tasks.

The core strength of the system lies in its sophisticated answer normalization process, which can handle diverse answer formats and representations while maintaining precise numerical comparison. The `get_normalized_prediction` function effectively parses model outputs, removing formatting artifacts and converting various numerical representations into a standardized form for comparison.

The modular design of the evaluation pipeline allows for easy extension to new datasets and evaluation scenarios. The system's ability to handle different data formats (TSV, JSON, JSONL) and evaluation types (numerical, multiple-choice) demonstrates its flexibility and adaptability. This makes it well-suited for both current numerical reasoning benchmarks and potential future additions.

For optimal use of the system, practitioners should carefully configure the evaluation parameters based on their specific needs, leveraging the command-line interface to control model selection, dataset choice, and evaluation settings. The detailed output format provides rich information for analyzing model performance, enabling targeted improvements to instruction strategies and model fine-tuning approaches.

As numerical reasoning remains a critical capability for language models, this evaluation system provides valuable tools for measuring progress and identifying areas for improvement in mathematical problem-solving abilities.