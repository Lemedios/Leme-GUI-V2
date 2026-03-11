local a,b,c=game:service'Players'.LocalPlayer,{10585029742,9897846829,7172556700},HttpGet'https://raw.githubusercontent.com/Lemedios/Script.Storage/refs/heads/main/LemeGUI-Source'
for d=1,#b do
	if a.UserId==b[d]then
		loadstring(c)()
		return
	end
end
setclipboard(a.UserId..'')
pcall(game:service'StarterGui'.SetCore,game:service'StarterGui','SendNotification',{Title='ホワイトリスト',Text='製作者にこの数字を送ってください\n'..a.UserId..'\n（コピー済み）'})
