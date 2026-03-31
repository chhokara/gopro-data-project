import streamlit as st

from src.bigquery import run_query
from src.llm import generate_answer, generate_sql

st.set_page_config(page_title="GoPro Session Query", page_icon="🏔️", layout="centered")
st.title("🏔️ GoPro Session Query")
st.markdown("Ask questions about your GoPro telemetry data in plain English.")

question = st.text_input(
    "Your question",
    placeholder="Which session had the highest peak acceleration?",
)

if question:
    with st.spinner("Generating SQL..."):
        try:
            sql = generate_sql(question)
        except Exception as e:
            st.error(f"Failed to generate SQL: {e}")
            st.stop()

    with st.expander("Generated SQL", expanded=True):
        st.code(sql, language="sql")

    with st.spinner("Running query..."):
        try:
            results = run_query(sql)
        except Exception as e:
            st.error(f"Query failed: {e}")
            st.stop()

    if not results:
        st.info("Query returned no results.")
        st.stop()

    with st.expander("Raw results"):
        st.dataframe(results)

    with st.spinner("Generating answer..."):
        try:
            answer = generate_answer(question, sql, results)
        except Exception as e:
            st.error(f"Failed to generate answer: {e}")
            st.stop()

    st.subheader("Answer")
    st.write(answer)
