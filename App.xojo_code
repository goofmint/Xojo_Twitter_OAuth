#tag Class
Protected Class App
Inherits WebApplication
	#tag Event
		Function HandleURL(Request As WebRequest) As Boolean
		  if Request.Path = "callback" then
		    
		    Self.Twitter.setOauthToken(Self.Twitter.analyseResponse(Request.QueryString))
		    if Self.Twitter.getAccessToken() then
		      Request.Status = 301
		      Request.Header("Location") = "http://localhost:8080/"
		      return True
		    end if
		  end if
		End Function
	#tag EndEvent


	#tag Property, Flags = &h0
		Twitter As Twitter
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
