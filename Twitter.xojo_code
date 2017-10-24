#tag Class
Protected Class Twitter
	#tag Method, Flags = &h0
		Function analyseResponse(response as String) As Dictionary
		  Dim responses() as String = response.Split("&")
		  Dim queries as Dictionary = new Dictionary
		  Dim values() as String
		  Dim i as Integer
		  For i = 0 to UBound(responses)
		    values = responses(i).split("=")
		    queries.Value(values(0)) = values(1)
		  Next
		  
		  return queries
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub constructor(consumerKey as String, consumerSecret as String)
		  Self.consumerKey = consumerKey
		  Self.consumerSecret = consumerSecret
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function encodeParams(params as Dictionary) As String()
		  Dim aryParams() as String
		  Dim value as string
		  Dim k as String
		  For each k in params.Keys
		    value = params.Value(k)
		    value = EncodeURLComponent(value)
		    aryParams.Append(k + "=" + value)
		  Next
		  
		  aryParams.Sort
		  return aryParams
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function generateSignature(method as string, requestUrl as string, aryParams() as String, accessTokenSecret as String) As string
		  Dim requestParams as String = Join(aryParams, "&")
		  requestParams = EncodeURLComponent(requestParams)
		  
		  Dim signatureData as String = EncodeURLComponent(method) + "&" + EncodeURLComponent(requestUrl) + "&" + requestParams
		  
		  DIm signatureKey as String = EncodeURLComponent(Self.consumerSecret) + "&" + EncodeURLComponent(accessTokenSecret)
		  
		  return EncodeBase64(Crypto.HMAC(signatureKey, signatureData, Crypto.Algorithm.SHA1), 0)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getAccessToken() As Boolean
		  Dim method as string = "POST"
		  Dim requestUrl as String = "https://api.twitter.com/oauth/access_token"
		  
		  Dim aryParams() as String = Self.getAccessTokenParams()
		  
		  aryParams.Append("oauth_signature=" + EncodeURLComponent(Self.generateSignature(method, requestUrl, aryParams, Self.oauthTokenSecret)))
		  
		  Dim response as string = Self.post(requestUrl, aryParams)
		  
		  setOauthToken(analyseResponse(response))
		  
		  return True
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getAccessTokenParams() As String()
		  Dim params as Dictionary = Self.getBaseParams()
		  
		  params.Value("oauth_token") = Self.oauthToken
		  params.Value("oauth_consumer_key") = Self.consumerKey
		  params.Value("oauth_verifier") = Self.oauthVerifier
		  
		  return Self.encodeParams(params)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getAuthenticateUrl() As String
		  Dim method as string = "POST"
		  Dim requestUrl as String = "https://api.twitter.com/oauth/request_token"
		  
		  Dim aryParams() as String = Self.getAuthParams()
		  
		  aryParams.Append("oauth_signature=" + EncodeURLComponent(Self.generateSignature(method, requestUrl, aryParams, "")))
		  
		  Dim response as string = Self.post(requestUrl, aryParams)
		  
		  setOauthToken(analyseResponse(response))
		  
		  return "https://api.twitter.com/oauth/authenticate?oauth_token=" + Self.oauthToken
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getAuthParams() As String()
		  Dim params as Dictionary = Self.getBaseParams()
		  params.Value("oauth_callback") = ""
		  
		  return Self.encodeParams(params)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getBaseParams() As Dictionary
		  Dim params as Dictionary = new Dictionary
		  Dim timestamp as new Date
		  Dim unix as Integer = timestamp.TotalSeconds - 2082844800
		  params.Value("oauth_consumer_key") = Self.consumerKey
		  params.Value("oauth_signature_method") = "HMAC-SHA1"
		  params.Value("oauth_timestamp") = unix
		  params.Value("oauth_nonce") = Microseconds.ToText
		  params.Value("oauth_version") = "1.0"
		  
		  return params
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getTweetParams() As String()
		  Dim params as Dictionary = Self.getBaseParams()
		  
		  params.Value("oauth_token") = Self.oauthToken
		  
		  return Self.encodeParams(params)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function post(requestUrl as String, aryParams() as string) As String
		  Dim http as HTTPSecureSocket = new HTTPSecureSocket
		  http.SetRequestHeader("Authorization", "OAuth " + Join(aryParams, ","))
		  
		  return http.Post(requestUrl, 10)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function post(requestUrl as String, aryParams() as string,body as Dictionary) As String
		  Dim http as HTTPSecureSocket = new HTTPSecureSocket
		  http.SetRequestHeader("Authorization", "OAuth " + Join(aryParams, ","))
		  
		  http.SetFormData(body)
		  return http.Post(requestUrl, 10)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setOauthToken(params as Dictionary)
		  Self.oauthToken = params.Value("oauth_token")
		  
		  if params.HasKey("oauth_token_secret") then
		    Self.oauthTokenSecret = params.Value("oauth_token_secret")
		  end if
		  
		  if params.HasKey("oauth_verifier") then
		    Self.oauthVerifier = params.Value("oauth_verifier")
		  end if
		  
		  if params.HasKey("user_id") then
		    Self.user_id = params.Value("user_id")
		  end if
		  
		  if params.HasKey("screen_name") then
		    Self.screenName = params.Value("screen_name")
		  end if
		  
		  if params.HasKey("x_auth_expires") then
		    Self.xAuthExpires = params.Value("x_auth_expires")
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function tweet(tweet as String) As Boolean
		  Dim method as string = "POST"
		  Dim requestUrl as String = "https://api.twitter.com/1.1/statuses/update.json"
		  
		  Dim aryParams() as String = Self.getTweetParams()
		  aryParams.Append("status=" + EncodeURLComponent(tweet))
		  aryParams.Append("oauth_signature=" + EncodeURLComponent(Self.generateSignature(method, requestUrl, aryParams, Self.oauthTokenSecret)))
		  
		  Dim body as Dictionary = new Dictionary
		  body.Value("status") = tweet
		  
		  Dim response as string = Self.post(requestUrl, aryParams, body)
		  Dim json as JSONItem = new JSONItem(response)
		  
		  if json.Value("id_str") <> "" then
		    return True
		  end if
		  
		  
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		consumerKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		consumerSecret As String
	#tag EndProperty

	#tag Property, Flags = &h0
		oauthToken As String
	#tag EndProperty

	#tag Property, Flags = &h0
		oauthTokenSecret As String
	#tag EndProperty

	#tag Property, Flags = &h0
		oauthVerifier As String
	#tag EndProperty

	#tag Property, Flags = &h0
		screenName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		user_id As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		xAuthExpires As Integer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="consumerKey"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="consumerSecret"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="oauthToken"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="oauthTokenSecret"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="oauthVerifier"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="screenName"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="user_id"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="xAuthExpires"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
