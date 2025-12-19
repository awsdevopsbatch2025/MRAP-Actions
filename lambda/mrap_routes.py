import boto3
import os

s3control = boto3.client(
    "s3control",
    region_name=os.environ.get("CONTROL_PLANE_REGION", "us-east-1"),
)

def handler(event, context):
    account_id = event["account_id"]
    mrap_arn   = event["mrap_arn"]
    routes     = event["routes"]

    s3control.submit_multi_region_access_point_routes(
        AccountId=account_id,
        Mrap=mrap_arn,
        RouteUpdates=routes,
    )

    return {"status": "ok", "routes": routes}
