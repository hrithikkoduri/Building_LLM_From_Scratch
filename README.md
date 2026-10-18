# Building an LLM From Scratch

A hands-on, notebook-driven walkthrough of building a Large Language Model from scratch, following the
progression of data preparation tasks that come *before* the model itself: text tokenization, subword
tokenization with Byte Pair Encoding (BPE), and building input–target pairs plus a PyTorch `DataLoader`
for autoregressive training.

Everything here is implemented in Jupyter notebooks and runs against Edith Wharton's short story
[`the-verdict.txt`](the-verdict.txt) as the sample corpus.

## Repository contents

| File | Description |
| --- | --- |
| [`1_LLM_Tokenizer.ipynb`](1_LLM_Tokenizer.ipynb) | Data preparation and sampling. Reads `the-verdict.txt`, explores regex-based splitting, builds a vocabulary, maps tokens to ids, and implements a `SimpleTokenizerV1` class with `encode`/`decode`. |
| [`2_Byte_Pair_Encoding.ipynb`](2_Byte_Pair_Encoding.ipynb) | Subword tokenization with BPE using `tiktoken` (`gpt2` encoding), including encode/decode round-trips. |
| [`3_Creating_InpuTarget_Pairs.ipynb`](3_Creating_InpuTarget_Pairs.ipynb) | Creates input–target pairs with a sliding window and implements a `GPTDatasetV1` (`torch.utils.data.Dataset`) wrapped in a `DataLoader`. |
| [`the-verdict.txt`](the-verdict.txt) | Sample training text (Edith Wharton, "The Verdict", from *The Hermit and the Wild Woman, and Other Stories*), ~20,479 characters. |
| `.gitignore` | Ignores local virtual environment directories (`myvenv/`, `venv/`). |

## What each notebook covers

### 1. Tokenizer — `1_LLM_Tokenizer.ipynb`
- Loads `the-verdict.txt` and inspects its size and content.
- Splits text with regexes based on whitespace and punctuation, then removes empty strings.
- Builds a sorted vocabulary (`Vocabulary size: 1130` tokens) and a token → id mapping.
- Implements `SimpleTokenizerV1`:
  - `encode(text)`: splits on `(\s|--|[.,?:/;_!"()'])` and maps tokens to ids.
  - `decode(ids)`: joins ids back into text and cleans up spacing before punctuation.
- Notes that out-of-vocabulary words raise an error — the motivation for training on large corpora.

### 2. Byte Pair Encoding — `2_Byte_Pair_Encoding.ipynb`
- Subword tokenization: frequently used words stay intact, rare words are split into subwords
  (e.g. `"boys"` → `"boy"` + `"s"`).
- Uses `tiktoken` (`tiktoken.get_encoding("gpt2")`, tiktoken 0.8.0) to encode text into integer ids
  and decode them back.

### 3. Input–Target Pairs — `3_Creating_InpuTarget_Pairs.ipynb`
- Autoregressive, self-supervised objective: given an input block, predict the next token, masking out
  all future tokens.
- Encodes the full corpus with the GPT-2 BPE tokenizer (5,145 tokens) and drops the first 50 tokens.
- Implements a sliding-window `GPTDatasetV1(text, tokenizer, max_length, stride)` `Dataset`, where
  `max_length` is the context size and `stride` is the shift between consecutive input–target pairs.
- Provides `create_dataset_v1(...)` returning a configured `DataLoader`
  (`batch_size`, `shuffle`, `drop_last`, `num_workers`).
- Demonstrates the behavior with `batch_size=1, max_length=4, stride=2` and with
  `batch_size=8, stride=4`.

## Requirements

- Python 3.12 (notebooks were run on 3.12.7)
- [`tiktoken`](https://github.com/openai/tiktoken) 0.8.0
- [PyTorch](https://pytorch.org/) 2.5.1
- Jupyter Notebook / JupyterLab

## Getting started

```bash
# 1. Clone the repository
git clone https://github.com/hrithikkoduri/Building_LLM_From_Scratch.git
cd Building_LLM_From_Scratch

# 2. Create and activate a virtual environment (it is git-ignored)
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 3. Install the dependencies
pip install jupyter tiktoken torch

# 4. Launch Jupyter and open the notebooks in order
jupyter notebook
```

Run the notebooks in numeric order (`1_...` → `2_...` → `3_...`); each one builds on the previous.
All notebooks read `the-verdict.txt` from the repository root, so start Jupyter from there.

## Notes

- The `GPTDatasetV1.__init__` loop uses `range(0, len(token_ids) - max_length, stride)`, so the final
  window that would land exactly on the end of the text is not produced. This is intentional in the
  book's reference implementation but worth knowing when reasoning about how many samples you get.
- `create_dataset_v1` accepts `drop_last=True` by default, which avoids a short final batch and the
  loss spikes it can cause.
