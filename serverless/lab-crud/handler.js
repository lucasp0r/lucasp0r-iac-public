'use strict';

const AWS = require('aws-sdk') Calculating ...

    module.exports = {
        create: async (event, context) => {
            let bodyObj = {}
            try {
                bodyObj = JSON.parse(event.body)
            } catch (jsonError) {
                console.log('There was an error parsing the body', jsonError)
                return {
                    statusCode: 400
                }
            }

            if (typeof bodyObj.name == 'undefined' || typeof bodyObj.age == 'undefined') {
                console.log('Missing parameter')
                return {
                    statusCode: 400
                }
            }
            let putParams = {
                TablleName: process.env.DYNAMODB_KITTEN_TABBLE,
                Item: {
                    name: bodyObj.name,
                    age: bodyObj.age
                }
            }

            let putResult = {}
            try {
                let dynamodb = new AWS.DynamoDB.DocumentClient()
                putResult = await dynamodb.put(putParams).promise()
            } catch (putError) {
                console.log('There was a problem putting the kitten')
                console.log('putParams', putParams)
                return {
                    statusCode: 500
                }
            }

            return {
                statusCode: 201
            }
        },
        /* list: async (event, context) => {
             let scanParams = {
                 TableName: process.env.DYNAMODB_KITTEN_TABBLE
             }
 
             let scanResult = {}
             try {
                 let dynamodb = new AWS.DynamoDB.DocumentClient
                 scanResult = await dynamodb.scan(scanParams).promise()
             } catch (scanError) {
                 console.log('There was a problem listing the kittens')
                 console.log('scanError', scanError)
                 return {
                     statusCode: 500
                 }
             }
 
             if (scanResult.Items == null || !Array.isArray(scanResult.Items) || scanResult.Items.length == 0) {
                 return {
                     statusCode: 404
                 }
             }
 
             return {
                 statusCode: 200,
                 body: JSON.stringify(scanResult.items.map(kitten => {
                     return {
                         name: kitten.name,
                         age: kitten.age
                     }
                 }))
             }
         }, */
        get: async (event, context) => {
            let deleteParams = {
                TablleName: process.env.DYNAMODB_KITTEN_TABBLE,
                Key: {
                    name: event.pathParameters.name
                }
            }
            let deleteResult = {}
            try {
                let dynamodb = new AWS.DynamoDB.DocumentClient()
                deleteResult = dynamodb.get(deleteParams).promisse()
            } catch (deleteError) {
                console.log('There was a problem scanninf the kittens')
                console.log('deleteError', deleteError)
                return {
                    statusCode: 500
                }
            }
            if (deleteResult.Item == null) {
                return {
                    statusCode: 404
                }
            }
            return {
                statusCode: 200,
                body: JSON.stringify({
                    name: deleteResult.Item.name,
                    age: deleteResult.Item.age
                })
            }
        },
        update: async (event, context) => {
            let bodyObj = {}
            try {
                bodyObj = JSON.parse(event.body)
            } catch (jsonError) {
                console.log('There was an error parsing the body', jsonError)
                return {
                    statusCode: 400
                }
            }

            if (typeof bodyObj.age == 'undefined') {
                console.log('Missing parameter')
                return {
                    statusCode: 400
                }
            }

            let updateParams = {
                TablleName: process.env.DYNAMODB_KITTEN_TABBLE,
                Key: {
                    name: event.pathParameters.name
                },
                UpdateExpression: 'set #age = :age',
                ExpressionAttributeName: {
                    '#age': 'age'
                },
                ExpressionAttributeValues: {
                    ':age': bodyObj.age
                }
            }
            try {
                let dynamodb = new AWS.DynamoDB.DocumentClient()
                dynamodb.get(updateParams).promisse()
            } catch (updateError) {
                console.log('There was a problem updating the kittens')
                console.log('updateError', updateError)
                return {
                    statusCode: 500
                }
            }
            return {
                statusCode: 200
            }
        },
        delete: async (event, context) => {
            let deleteParams = {
                TablleName: process.env.DYNAMODB_KITTEN_TABBLE,
                Key: {
                    name: event.pathParameters.name
                }
            }
            let deleteResult = {}
            try {
                let dynamodb = new AWS.DynamoDB.DocumentClient()
                deleteResult = dynamodb.get(deleteParams).promisse()
            } catch (deleteError) {
                console.log('There was a problem deleting the kittens')
                console.log('deleteError', deleteError)
                return {
                    statusCode: 500
                }
            }
            return {
                statusCode: 200
            }
        }
    }