# Prompt Generation

<cite>
**Referenced Files in This Document**   
- [eval_utils.py](file://opro/evaluation/eval_utils.py)
- [MultiArith.json](file://data/MultiArith-data/MultiArith.json)
- [gsm_test.tsv](file://data/gsm_data/gsm_test.tsv)
- [abstract_algebra_test.csv](file://data/MMLU-data/test/abstract_algebra_test.csv)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Core Parameters](#core-parameters)
3. [Dataset-Specific Prompt Construction](#dataset-specific-prompt-construction)
4. [Instruction Position and QA Formatting](#instruction-position-and-qa-formatting)
5. [Internal Logic and Routing](#internal-logic-and-routing)
6. [Common Issues and Error Handling](#common-issues-and-error-handling)
7. [Performance Considerations](#performance-considerations)
8. [Code Examples](#code-examples)

## Introduction
The `gen_prompt` function in `opro/evaluation/eval_utils.py` is responsible for constructing dataset-specific prompts for various benchmarks including MMLU, BBH, GSM8K, MultiArith, and AQuA. This function takes into account the instruction position (before_Q, Q_begin, Q_end, A_begin) and QA formatting to generate appropriate prompts for different types of questions, whether multiple-choice or free-response. The function is designed to handle various data formats and ensure that the prompts are constructed correctly based on the dataset and the specific requirements of each benchmark.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L164-L259)

## Core Parameters
The `gen_prompt` function accepts several parameters that are crucial for its operation:
- **data**: This parameter can be a pandas DataFrame, a list, or a JSON object, depending on the dataset. It contains the input-output pairs for the specific benchmark.
- **instruction**: A string that represents the instruction to be included in the prompt.
- **idx**: An integer that specifies the index of the exemplar in the data list.
- **include_qa**: A boolean that determines whether to include "Q:" and "A:" formats in the prompt.
- **instruction_pos**: A string that specifies the position of the instruction within the prompt. It can be one of {'before_Q', 'Q_begin', 'Q_end', 'A_begin'}.
- **dataset_name**: A string that specifies the name of the dataset. It must be one of {"mmlu", "bbh", "gsm8k", "multiarith", "aqua"}.

These parameters are used to construct the prompt in a way that is consistent with the requirements of the specific benchmark.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L164-L259)

## Dataset-Specific Prompt Construction
The `gen_prompt` function constructs prompts differently based on the dataset. For each dataset, the function follows a specific logic to extract the question and format it appropriately.

### MMLU
For the MMLU dataset, the function uses the `_format_mmlu_example` function to generate the question part of the prompt. The MMLU dataset is stored in CSV files with no index or header, and the columns are: question, Choice A, Choice B, Choice C, Choice D, and the true answer in ABCD format. The function extracts the question and the choices, and appends a standard question sentence asking for the answer in (A) (B) (C) (D).

### BBH
For the BBH dataset, the function directly uses the `input` field from the data list. The BBH dataset is stored in a list format, and each entry contains an `input` field that represents the question.

### GSM8K
For the GSM8K dataset, the function uses the first column of the DataFrame to extract the question. The GSM8K dataset is stored in a TSV file, and the first column contains the question.

### MultiArith
For the MultiArith dataset, the function uses the `sQuestion` field from the JSON data. The MultiArith dataset is stored in a JSON file, and each entry contains an `sQuestion` field that represents the question.

### AQuA
For the AQuA dataset, the function uses the `_format_aqua_example` function to generate the question part of the prompt. The AQuA dataset is stored in a JSON file, and each entry contains a `question` field and an `options` field. The function extracts the question and the options, and appends a standard question sentence asking for the answer in (A) (B) (C) (D) (E).

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L211-L222)

## Instruction Position and QA Formatting
The `gen_prompt` function allows for flexible placement of the instruction within the prompt. The `instruction_pos` parameter determines where the instruction is placed. The possible values are:
- **before_Q**: The instruction is placed before the question.
- **Q_begin**: The instruction is placed at the beginning of the question.
- **Q_end**: The instruction is placed at the end of the question.
- **A_begin**: The instruction is placed at the beginning of the answer.

The `include_qa` parameter determines whether to include "Q:" and "A:" formats in the prompt. If `include_qa` is `True`, the function includes "Q:" before the question and "A:" before the answer. If `include_qa` is `False`, the function does not include these formats.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L223-L259)

## Internal Logic and Routing
The `gen_prompt` function uses a series of conditional statements to determine the appropriate logic for each dataset. The function first converts the `dataset_name` to lowercase and checks if it is one of the supported datasets. If the dataset is not supported, the function raises an assertion error.

For each supported dataset, the function calls the appropriate helper function to format the question. For MMLU, it calls `_format_mmlu_example`. For AQuA, it calls `_format_aqua_example`. For the other datasets, it directly extracts the question from the data.

The function then constructs the prompt based on the `instruction_pos` and `include_qa` parameters. If `include_qa` is `True`, the function includes "Q:" and "A:" in the prompt. The instruction is placed according to the `instruction_pos` parameter.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L190-L259)

## Common Issues and Error Handling
The `gen_prompt` function includes several checks to ensure that the input parameters are valid. If the `dataset_name` is not one of the supported datasets, the function raises an assertion error. Similarly, if the `instruction_pos` is not one of the supported values, the function raises an assertion error.

The function also handles cases where the instruction is empty. If the instruction is empty, the function does not include it in the prompt.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L190-L209)

## Performance Considerations
When generating prompts in batch, the `gen_prompt` function can be called multiple times. To optimize performance, it is recommended to pre-process the data and store it in a format that can be quickly accessed. For example, if the data is stored in a DataFrame, it can be converted to a dictionary for faster access.

Additionally, the function can be parallelized to generate multiple prompts simultaneously. This can be achieved by using multithreading or multiprocessing to call the function with different indices in parallel.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L634-L645)

## Code Examples
Here are some code examples showing how to use the `gen_prompt` function for different datasets and instruction positions.

### Multiple-Choice Format
```python
# Example for MMLU
data = pd.read_csv('data/MMLU-data/test/abstract_algebra_test.csv', header=None)
instruction = "Solve the following problem:"
idx = 0
include_qa = True
instruction_pos = "Q_begin"
dataset_name = "mmlu"
prompt = gen_prompt(data, instruction, idx, include_qa, instruction_pos, dataset_name)
print(prompt)
```

### Free-Response Format
```python
# Example for GSM8K
data = pd.read_csv('data/gsm_data/gsm_test.tsv', sep='\t', header=None)
instruction = "Solve the following problem:"
idx = 0
include_qa = True
instruction_pos = "Q_begin"
dataset_name = "gsm8k"
prompt = gen_prompt(data, instruction, idx, include_qa, instruction_pos, dataset_name)
print(prompt)
```

### BBH Example
```python
# Example for BBH
data = [
    {"input": "What is the capital of France?", "target": "Paris"},
    {"input": "What is the largest planet in our solar system?", "target": "Jupiter"}
]
instruction = "Answer the following question:"
idx = 0
include_qa = True
instruction_pos = "Q_begin"
dataset_name = "bbh"
prompt = gen_prompt(data, instruction, idx, include_qa, instruction_pos, dataset_name)
print(prompt)
```

### MultiArith Example
```python
# Example for MultiArith
import json
with open('data/MultiArith-data/MultiArith.json', 'r') as f:
    data = json.load(f)
instruction = "Solve the following arithmetic problem:"
idx = 0
include_qa = True
instruction_pos = "Q_begin"
dataset_name = "multiarith"
prompt = gen_prompt(data, instruction, idx, include_qa, instruction_pos, dataset_name)
print(prompt)
```

### AQuA Example
```python
# Example for AQuA
import json
with open('data/AQuA-data/AQuA.json', 'r') as f:
    data = json.load(f)
instruction = "Solve the following problem:"
idx = 0
include_qa = True
instruction_pos = "Q_begin"
dataset_name = "aqua"
prompt = gen_prompt(data, instruction, idx, include_qa, instruction_pos, dataset_name)
print(prompt)
```

These examples demonstrate how to use the `gen_prompt` function for different datasets and instruction positions. The function is flexible and can handle various data formats and prompt structures.

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L164-L259)
- [abstract_algebra_test.csv](file://data/MMLU-data/test/abstract_algebra_test.csv)
- [gsm_test.tsv](file://data/gsm_data/gsm_test.tsv)
- [MultiArith.json](file://data/MultiArith-data/MultiArith.json)
- [AQuA.json](file://data/AQuA-data/AQuA.json)