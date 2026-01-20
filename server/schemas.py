import datetime as _dt

import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    title: str| None
    # data_created: str

    class Config:
        orm_mode = True


class PublicKeyResponse(PublicKeyRequest_Base):
    public_key: str| None
    expires_in: str| None
    hashed_token: str| None

    class Config:
        orm_mode = True


class DataResponse(_pydantic.BaseModel):
    image: bytes| None
    in_token: str| None

    class Config:
        orm_mode = True
