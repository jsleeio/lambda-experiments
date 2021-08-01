// adapted from https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

// Event is used to unmarshal the Lambda event context
type Event struct {
	Name string `json:"name"`
}

// Response represents the Response object
type Response struct {
	Message string `json:"Message"`
}

// HandleRequest handles a single request from the Lambda runtime
func HandleRequest(ctx context.Context, name Event) (Response, error) {
	return Response{Message: fmt.Sprintf("%s! hi m8", name.Name)}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
