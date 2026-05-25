from pydantic import BaseModel


class LlmQueryRequest(BaseModel):
    query_type: str
    query_text: str
    user_email: str


class LlmQueryResponse(BaseModel):
    success: bool
    response: str
