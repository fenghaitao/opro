# Error Handling and Troubleshooting

<cite>
**Referenced Files in This Document**   
- [prompt_utils.py](file://opro/prompt_utils.py)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py)
- [opt_utils.py](file://opro/optimization/opt_utils.py)
- [eval_utils.py](file://opro/evaluation/eval_utils.py)
- [metrics.py](file://opro/evaluation/metrics.py)
- [README.md](file://README.md)
- [data/README.md](file://data/README.md)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Common Error Categories](#common-error-categories)
3. [API Authentication and Connectivity Issues](#api-authentication-and-connectivity-issues)
4. [Rate Limiting and Timeout Handling](#rate-limiting-and-timeout-handling)
5. [Response Parsing and Validation](#response-parsing-and-validation)
6. [Dataset-Specific Errors](#dataset-specific-errors)
7. [LLM Output Handling and Retry Mechanisms](#llm-output-handling-and-retry-mechanisms)
8. [Diagnostic Information and Logging](#diagnostic-information-and-logging)
9. [Troubleshooting Checklist](#troubleshooting-checklist)
10. [Interpreting Error Messages](#interpreting-error-messages)

## Introduction
This document provides comprehensive troubleshooting guidance for the opro system, which uses large language models as optimizers for prompt engineering. The system integrates with external LLM APIs from OpenAI and Google's PaLM to optimize and evaluate instructions across various benchmark datasets. Common issues include API authentication failures, rate limiting, malformed responses, parsing errors, and timeout issues. This guide explains how the system handles retries, failed generations, and invalid outputs from LLMs, providing diagnostic steps and solutions for users encountering problems.

**Section sources**
- [README.md](file://README.md#L1-L79)

## Common Error Categories
The opro system encounters several categories of errors during operation. API authentication failures occur when invalid or missing API keys prevent access to external LLM services. Rate limiting errors happen when the system exceeds API call quotas, particularly during intensive optimization processes. Malformed responses can result from LLMs generating outputs that don't conform to expected formats, making parsing difficult. Parsing errors occur when the system fails to extract meaningful information from LLM responses, particularly when dealing with numerical answers or multiple-choice questions. Timeout issues arise when API requests take longer than expected to complete, often due to network latency or server load.

The system handles different dataset types with specific parsing requirements: MMLU (Massive Multitask Language Understanding) uses multiple-choice questions with lettered options, BBH (Big-Bench Hard) includes various question types including boolean expressions and numerical reasoning, and GSM8K focuses on grade school math problems requiring numerical answers. Each dataset type has specific validation rules that can trigger errors if not properly handled.

**Section sources**
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L133)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L1-L770)

## API Authentication and Connectivity Issues
API authentication failures are among the most common issues in the opro system. When using Google's PaLM API, users must provide a valid API key through the `--palm_api_key` parameter. The system explicitly checks for this key and raises an assertion error if it's missing, displaying the message: "A PaLM API key is needed when prompting the text-bison model." Similarly, when using OpenAI models, the `--openai_api_key` parameter must be provided, with the system checking for its presence and displaying "The OpenAI API key must be provided" if missing.

Connectivity issues can occur due to network problems or API service unavailability. The system includes diagnostic steps to verify API connectivity by testing with simple prompts. For example, both the optimization and evaluation scripts include test calls to the LLM servers using a simple question like "Does the sun rise from the north? Just answer yes or no." This helps users confirm that their API keys are valid and that they can successfully communicate with the LLM services before running more complex operations.

To resolve authentication issues, users should verify that they have obtained valid API keys from the respective providers and that these keys are correctly passed to the scripts. For OpenAI, users should check their account at platform.openai.com to ensure their API key is active and has sufficient credits. For PaLM, users should verify their Google Cloud project has the necessary APIs enabled and billing configured.

**Section sources**
- [prompt_utils.py](file://opro/prompt_utils.py#L17-L18)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L65-L70)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L63-L68)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L191-L209)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L185-L193)

## Rate Limiting and Timeout Handling
The opro system implements comprehensive retry mechanisms to handle rate limiting and timeout issues when communicating with external LLM APIs. For OpenAI API calls, the system catches specific exception types and implements exponential backoff with retry delays. When a `Timeout` error occurs, the system waits for a specified retry time (default 30 seconds) before retrying the request. Similarly, for `RateLimitError`, the system respects the `retry_after` header if provided by the API, otherwise defaulting to a 30-second delay.

The retry logic is implemented recursively in the `call_openai_server_single_prompt` function, which catches various OpenAI-specific exceptions including `APIError`, `APIConnectionError`, and `ServiceUnavailableError`. Each exception type triggers a retry after a delay, with the function calling itself to attempt the request again. This approach ensures that transient network issues or temporary API overloads don't immediately terminate the optimization or evaluation process.

For Google's PaLM API, the system implements a simpler retry mechanism with a fixed 10-second delay between attempts. The `call_palm_server_from_cloud` function includes a bare except clause that catches any exception during the API call and retries after sleeping for 10 seconds. While this approach is less specific than the OpenAI error handling, it provides basic resilience against temporary connectivity issues.

Users can mitigate rate limiting issues by monitoring their API usage quotas and adjusting their workflow accordingly. The system documentation advises users to "carefully estimate the cost and/or start with lighter use" to avoid unexpectedly large costs from excessive API calls. Running optimization for fewer steps or evaluating on a smaller portion of the benchmark dataset can help stay within rate limits.

**Section sources**
- [prompt_utils.py](file://opro/prompt_utils.py#L36-L84)
- [prompt_utils.py](file://opro/prompt_utils.py#L126-L132)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L355-L368)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L296-L302)

## Response Parsing and Validation
The opro system employs sophisticated parsing mechanisms to extract and validate responses from LLMs, particularly for numerical and multiple-choice questions. The parsing logic varies depending on the dataset type and expected answer format. For numerical answers in datasets like GSM8K, the system uses the `get_normalized_prediction` function in metrics.py, which applies various text processing rules to extract numbers from model outputs. This includes handling patterns like "the answer is 42" or "42 is the final answer" by searching for specific delimiters and extracting the numerical portion.

For multiple-choice questions in MMLU and BBH datasets, the system implements several validation strategies. It can identify answers in various formats including lettered choices in parentheses like "(A)", boolean responses like "yes/no" or "true/false", and validity judgments like "valid/invalid". The system uses regular expressions to extract bracketed choices and compares them against the expected answer. It also implements fuzzy matching that considers the semantic meaning of responses, such as treating "1" as equivalent to "true" in boolean contexts.

Parsing errors can occur when LLMs generate responses that don't conform to expected patterns. The system handles this by implementing fallback strategies, such as looking for the answer in different parts of the response or applying different parsing rules. For example, when extracting answers from chain-of-thought reasoning, the system may look for the final answer after phrases like "So the final answer is" or "Therefore, the answer is."

Users can diagnose parsing issues by examining the raw model outputs and comparing them to the expected format. The system saves detailed results including raw prompts, raw answers, parsed answers, and true answers in CSV files, allowing users to identify where parsing failures occur. Adjusting the instruction format or using different parsing strategies can help resolve persistent parsing issues.

**Section sources**
- [metrics.py](file://opro/evaluation/metrics.py#L1-L496)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L381-L490)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L779-L787)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L715-L740)

## Dataset-Specific Errors
The opro system handles several benchmark datasets, each with specific requirements and potential error modes. Dataset-specific errors typically arise from missing files, format mismatches, or incorrect task specifications. The system supports MMLU, BBH, GSM8K, MultiArith, and AQuA datasets, each with distinct file formats and organizational structures.

For MMLU data, errors can occur if the required CSV files are missing from the `data/MMLU-data/test/` directory. Each subject area has its own CSV file (e.g., `abstract_algebra_test.csv`, `anatomy_test.csv`), and the system expects these files to follow a specific format with questions, multiple-choice options, and answer keys. When processing MMLU data, the system uses pandas to read CSV files with no index or header, expecting columns for the question, four answer choices (A-D), and the correct answer in ABCD format.

BBH dataset errors often stem from missing JSON files in the expected directory structure. The system looks for BBH task data in JSON format, with each task having its own file (e.g., `boolean_expressions.json`). The `load_bbh_task_data` function explicitly checks if the requested task exists among available files, raising a `ValueError` with the message "Task {task_name} not a valid bbh task" if the file is missing. Users must ensure they have downloaded the complete BBH dataset and placed it in the correct directory.

GSM8K and MultiArith datasets use TSV and JSON formats respectively, with specific field requirements. GSM8K data is stored in TSV files (`gsm_train.tsv`, `gsm_test.tsv`) with two columns: the question and the answer. MultiArith data is in JSON format with fields for the question and solution. Format mismatches, such as incorrect delimiters or missing fields, will cause parsing errors during data loading.

To prevent dataset-specific errors, users should verify that all required data files are present in the correct locations and follow the expected formats. The `data/README.md` file provides information about the source of each dataset and any preprocessing that has been applied. Users encountering dataset errors should first check this documentation and verify their data directory structure matches the expected layout.

**Section sources**
- [data/README.md](file://data/README.md#L1-L31)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L608-L628)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L556-L616)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L877-L915)

## LLM Output Handling and Retry Mechanisms
The opro system implements robust mechanisms for handling LLM outputs and managing failed generations. When LLMs produce invalid or suboptimal outputs, the system employs several strategies to ensure reliable operation. For instruction generation, the system filters out generated instructions that exceed length limits (over 500 characters) or contain problematic content like numbers in GSM8K tasks or the placeholder "INS" string.

The retry mechanisms for LLM calls are implemented at multiple levels. At the API client level, both OpenAI and PaLM integrations include automatic retry logic for transient errors. At the application level, the optimization process maintains a history of previously evaluated instructions using MD5 hashing to avoid redundant evaluations. This prevents the system from wasting API calls on instructions it has already processed, even if they are generated again by the optimizer LLM.

For evaluation tasks, the system implements a comprehensive error handling strategy in the `evaluate_single_instruction` function. This function includes multiple retry attempts (configurable via the `max_retry` parameter) with configurable sleep times between attempts. The default configuration allows for 5 retries with 180-second delays, providing resilience against temporary API issues. The function also supports parallel evaluation through multithreading, which can be disabled for GPT models that may have stricter rate limits on concurrent requests.

When handling failed generations, the system distinguishes between different types of errors. Transient errors like timeouts or rate limits trigger automatic retries, while permanent errors like authentication failures terminate the process with a clear error message. The system also handles cases where LLMs generate malformed outputs by implementing fallback parsing strategies and validation checks.

Users can optimize LLM output handling by adjusting the retry parameters based on their specific use case and API provider limitations. For example, when working with rate-limited APIs, increasing the sleep time between retries can prevent repeated rate limit errors. Monitoring the detailed results files can help identify patterns in failed generations, allowing users to refine their instructions or adjust system parameters accordingly.

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L790-L823)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L338-L378)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L698-L700)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L733-L735)

## Diagnostic Information and Logging
The opro system provides extensive diagnostic information through structured logging and output files, enabling users to troubleshoot issues effectively. The system generates detailed logs during execution, including information about API calls, error conditions, and retry attempts. These logs are displayed in the console output, providing real-time feedback on the system's operation.

The primary diagnostic outputs are saved in structured directories within the `outputs` folder. For optimization tasks, results are stored in `outputs/optimization-results/` with timestamped subdirectories containing detailed results. For evaluation tasks, results are saved in `outputs/scorer-outputs/` following a similar structure. Each results directory contains CSV files with detailed information about each evaluated instruction, including raw prompts, model responses, parsed answers, and accuracy scores.

Key diagnostic files include:
- `scorer_configs.json`: Contains the configuration parameters used for the scorer LLM
- `configs_dict.json`: Stores the complete configuration for optimization runs
- `results_dict.pkl`: Pickle file containing comprehensive results data including meta-prompts and evaluation scores
- Individual CSV files for each instruction, named using MD5 hashes of the instruction content

The system also generates intermediate files in the `misc/prompt_history/` directory, which contains text files of prompt interactions with the LLMs. These files can be invaluable for diagnosing issues with specific instructions or understanding how the optimizer is refining prompts over time.

Users can locate diagnostic information by checking the output directory specified in the console output during script execution. The system prints the result directory path at the beginning of each run, making it easy to find the relevant files. Examining these files can help identify patterns in errors, such as consistent parsing failures or systematic accuracy issues with certain types of instructions.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L222-L238)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L222-L236)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L642-L645)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L424-L426)

## Troubleshooting Checklist
When encountering issues with the opro system, users should follow this systematic troubleshooting checklist:

1. **Verify API keys**: Confirm that both `--palm_api_key` and `--openai_api_key` parameters are provided when required, and that the keys are valid and active.

2. **Check data files**: Ensure all required dataset files are present in the correct locations, particularly the MMLU CSV files in `data/MMLU-data/test/`, BBH JSON files, and GSM8K TSV files.

3. **Test basic connectivity**: Run a simple test with a minimal prompt to verify API connectivity before executing complex optimization or evaluation tasks.

4. **Review error messages**: Examine console output for specific error messages, paying attention to exception types and error descriptions.

5. **Check output directories**: Look for diagnostic files in the `outputs` directory, particularly configuration files and detailed results CSVs.

6. **Validate instruction format**: Ensure instructions follow the expected format for the target dataset, avoiding prohibited content like numbers in GSM8K tasks.

7. **Monitor API usage**: Check API provider dashboards for rate limit status and usage quotas to avoid throttling.

8. **Adjust retry parameters**: If experiencing timeout or rate limit issues, consider increasing retry delays or reducing concurrency.

9. **Examine parsing results**: Review the parsed answers in output CSV files to identify parsing failures and adjust instructions accordingly.

10. **Consult documentation**: Refer to the README files and code comments for specific requirements and limitations of each component.

Following this checklist systematically can resolve most common issues with the opro system. For persistent problems, users should collect relevant log files and error messages to provide detailed information when seeking support.

**Section sources**
- [README.md](file://README.md#L1-L79)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L32-L35)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L26-L31)
- [data/README.md](file://data/README.md#L1-L31)

## Interpreting Error Messages
Understanding the error messages generated by the opro system is crucial for effective troubleshooting. The system produces various error types, each with specific meanings and resolution strategies.

Assertion errors typically indicate configuration issues. For example, "The OpenAI API key must be provided" means the `--openai_api_key` parameter is missing or empty. Similarly, "A PaLM API key is needed when prompting the text-bison model" indicates the `--palm_api_key` parameter is required but not provided. These errors require users to supply the appropriate API keys.

Value errors often relate to invalid parameters or missing data. The error "Task {task_name} not a valid bbh task" indicates that the requested BBH task doesn't have a corresponding JSON file in the data directory. This requires users to verify the task name and ensure the complete BBH dataset is properly installed.

API-specific exceptions provide detailed information about communication issues:
- `Timeout`: The API request took too long to complete
- `RateLimitError`: The API rate limit has been exceeded
- `APIConnectionError`: Network connectivity issues prevented the request
- `ServiceUnavailableError`: The API service is temporarily unavailable

Console messages like "Retrying in {retry_time} seconds..." indicate the system is automatically handling transient errors through its retry mechanism. While these are informational rather than errors, frequent retry messages may suggest network instability or API service issues.

When examining stack traces, users should focus on the final exception, which represents the actual error, rather than the intermediate function calls. The line numbers in error messages can help locate the specific code causing the issue, particularly in the main execution scripts like `optimize_instructions.py` and `evaluate_instructions.py`.

Understanding these error messages allows users to quickly diagnose and resolve issues, minimizing downtime and ensuring smooth operation of the opro system.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L113-L157)
- [prompt_utils.py](file://opro/prompt_utils.py#L36-L84)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L897-L901)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L355-L368)