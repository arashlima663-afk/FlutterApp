import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    owner_id: str
    clientPublicKeyBase64: str
    
    model_config = _pydantic.ConfigDict(from_attributes=True)


class PublicKeyResponse(_pydantic.BaseModel):
    owner_id: str
    pub_key: str
    jwt: str

    model_config = _pydantic.ConfigDict(from_attributes=True)

class DataResponse(_pydantic.BaseModel):
    owner_id: str
    img: str 
    jwt: str
    nonce: str
    tag: str
    
    model_config = _pydantic.ConfigDict(from_attributes=True)



class Test(_pydantic.BaseModel):
    title:str = None
    
    model_config = _pydantic.ConfigDict(from_attributes=True)

