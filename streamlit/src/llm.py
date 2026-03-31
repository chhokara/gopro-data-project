import json

import anthropic

from src.prompts import ANSWER_SYSTEM_PROMPT, SQL_SYSTEM_PROMPT


def generate_sql(question: str) -> str:
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=1024,
        system=SQL_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": question}],
    )
    return response.content[0].text.strip()


def generate_answer(question: str, sql: str, results: list[dict]) -> str:
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=1024,
        system=ANSWER_SYSTEM_PROMPT,
        messages=[
            {
                "role": "user",
                "content": (
                    f"Question: {question}\n\n"
                    f"SQL:\n{sql}\n\n"
                    f"Results:\n{json.dumps(results, indent=2, default=str)}"
                ),
            }
        ],
    )
    for block in response.content:
        if block.type == "text":
            return block.text
    return ""
