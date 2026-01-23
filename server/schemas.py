import datetime as _dt
import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    title: str
    owner_id : str
    date_created: int = None

    model_config = _pydantic.ConfigDict(from_attributes=True)


class PublicKeyResponse(PublicKeyRequest_Base):
    pub_key: str
    exp: int | None
    jwt: str

    model_config = _pydantic.ConfigDict(from_attributes=True)

class DataResponse(_pydantic.BaseModel):
    owner_id : str | None = None
    encrypted_aes: str
    img: bytes | None
    jwt: str
    

    model_config = _pydantic.ConfigDict(from_attributes=True)



if __name__ == "__main__":
    m = PublicKeyResponse(public_key="abcd", expires_in= 1234, jwt="effe")
    m.public_key
