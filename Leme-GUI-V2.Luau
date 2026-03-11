local a,b=game:service'Players'.LocalPlayer,{10585029742,9897846829,7172556700}
for c=1,#b do
	if a.UserId==b[c]then
		loadstring(HttpGet'https://raw.githubusercontent.com/Lemedios/Script.Storage/refs/heads/main/LemeGUI-Source')()
		return
	end
end
setclipboard(a.UserId..'')
pcall(game:service'StarterGui'.SetCore,game:service'StarterGui','SendNotification',{Title='Whitelist',Text='製作者にこの数字を送ってください\n'..a.UserId..'\n（コピー済み）'})
