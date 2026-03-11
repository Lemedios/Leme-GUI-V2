local a,b,c,d=game:service'Players'.LocalPlayer,{10585029742,9897846829,7172556700},HttpGet'https://raw.githubusercontent.com/Lemedios/Script.Storage/refs/heads/main/LemeGUI-Source',game:service'StarterGui'
for e=1,#b do
	if a.UserId==b[e]then
		e=loadstring
		if e then
			e,e=e(c)
			if e then e()end
		end
		return
	end
end
setclipboard(a.UserId..'')
pcall(d.SetCore,d,'SendNotification',{Title='ホワイトリスト',Text='製作者にこの数字を送ってください\n'..a.UserId..'\n（コピー済み）'})
