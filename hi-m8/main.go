// adapted from https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// HandleRequest handles a single request from the Lambda runtime
func HandleRequest(ctx context.Context, event events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	headers := make(map[string]string)
	headers["Content-type"] = "text/plain"
	name, ok := event.QueryStringParameters["name"]
	if !ok {
		return events.APIGatewayV2HTTPResponse{
			Headers:    headers,
			StatusCode: 400,
			Body:       "GTFO"}, nil
	}
	return events.APIGatewayV2HTTPResponse{
		StatusCode: 200,
		Body:       fmt.Sprintf("%s! hi m8", name),
		Headers:    headers}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
