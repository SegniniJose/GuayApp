extends PanelContainer
class_name PendingOutboundInvitationCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName
@onready var invitation: RichTextLabel = %Invitation


func set_pending_outbound_invitation(pending_outbound_invitation: Dictionary):
	print("set_pending_outbound_invitation ", pending_outbound_invitation)
	if pending_outbound_invitation.has("user"):
		friend_name.text = pending_outbound_invitation.user.username
		await avatar.set_url(pending_outbound_invitation.user.avatar)
