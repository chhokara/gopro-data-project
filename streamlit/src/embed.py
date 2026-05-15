"""
embed.py

Converts DbtModelChunk objects into embedding vectors using the OpenAI
text-embedding-3-small model. Requires OPENAI_API_KEY in the environment.
"""

from openai import OpenAI

from src.parse_dbt import DbtModelChunk

_MODEL = "text-embedding-3-small"


def embed_chunks(chunks: list[DbtModelChunk]) -> list[tuple[DbtModelChunk, list[float]]]:
    """
    Embeds each chunk's text and returns it paired with its vector.

    Args:
        chunks: parsed dbt model chunks from parse_dbt.parse_dbt_models()

    Returns:
        List of (chunk, vector) pairs in the same order as the input.
    """
    client = OpenAI()
    texts = [chunk.to_chunk_text() for chunk in chunks]

    response = client.embeddings.create(model=_MODEL, input=texts)

    # response.data is ordered to match the input list
    vectors = [item.embedding for item in response.data]
    return list(zip(chunks, vectors))


def embed_query(question: str) -> list[float]:
    """
    Embeds a user question for similarity search against stored chunk vectors.
    Must use the same model as embed_chunks.

    Args:
        question: the user's natural language question

    Returns:
        Embedding vector as a list of floats.
    """
    client = OpenAI()
    response = client.embeddings.create(model=_MODEL, input=[question])
    return response.data[0].embedding
