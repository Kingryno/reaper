# Reaper prank. Harmless: fullscreen window, laugh from a hosted audio file, blackout, fake terminal, closes itself.
# Nothing written to disk, no settings changed, no persistence.

$LaughUrl        = 'https://raw.githubusercontent.com/Kingryno/reaper/main/Crypt_Keeper_Laugh.mp3'
$LaughSeconds    = 6.5
$BlackSeconds    = 4
$FinaleSeconds   = 2

Add-Type -AssemblyName System.Windows.Forms, PresentationCore
[Windows.Forms.Cursor]::Hide()

$f = New-Object Windows.Forms.Form -Property @{ FormBorderStyle=0; WindowState=2; BackColor='Black'; TopMost=$true; ShowInTaskbar=$false }
$skull = New-Object Windows.Forms.Label -Property @{ Dock=5; TextAlign=32; ForeColor='Silver'; Font='Segoe UI Symbol,400'; Text=[char]0x2620 }
$tag   = New-Object Windows.Forms.Label -Property @{ Dock=2; Height=200; TextAlign=32; ForeColor='DarkRed'; Font='Impact,90'; Text='YOUR TIME IS NEAR' }
$f.Controls.AddRange(@($skull, $tag))
$f.Show(); $f.Activate()

$pump = { [Windows.Forms.Application]::DoEvents(); Start-Sleep -m 30 }
$wait = { param($n) $t = Get-Date; while (((Get-Date) - $t).TotalSeconds -lt $n) { & $pump } }

# Laugh (mp3 or wav over HTTPS) with a flicker on the skull while it plays
$m = New-Object Windows.Media.MediaPlayer
$m.Volume = 1.0
$m.Open($LaughUrl)
$m.Play()
$t = Get-Date
while (((Get-Date) - $t).TotalSeconds -lt $LaughSeconds) {
    $skull.ForeColor = if ((Get-Random -Max 10) -lt 2) { 'DimGray' } else { 'Silver' }
    & $pump
}
$m.Stop(); $m.Close()

# Blackout
$skull.Hide(); $tag.Hide()
& $wait $BlackSeconds

# Terminal
$term = New-Object Windows.Forms.TextBox -Property @{ Multiline=$true; Dock=5; BackColor='Black'; ForeColor='Lime'; Font='Consolas,16'; BorderStyle=0; ReadOnly=$true; TabStop=$false }
$f.Controls.Add($term)

$u = $env:USERNAME; $h = $env:COMPUTERNAME
$rnd = New-Object Random
function Hex($n) { -join (1..$n | ForEach-Object { '{0:x2}' -f $rnd.Next(256) }) }
function Dump() { "    {0:x8}  {1} {2} {3} {4}" -f $rnd.Next(), (Hex 4), (Hex 4), (Hex 4), (Hex 4) }
$souls = 'weak', 'fragile', 'unguarded', 'ripe', 'overdue'

$lines = @(
    'REAPER v6.6.6 :: soul acquisition framework'
    "[*] session opened on $h as $u"
    '[*] enumerating local network'
)
1..6 | ForEach-Object { $lines += "[+] 192.168.1.$($rnd.Next(2,254))   alive   soul=$($souls[$rnd.Next($souls.Count)])" }
$lines += "[*] fingerprinting $u"
1..10 | ForEach-Object { $lines += Dump }
$lines += '[*] cracking free will'
$lines += 'BAR'
$lines += '[+] regrets .......... 1,402 indexed'
$lines += '[+] memories ......... 100% copied'
$lines += '[*] opening channel to the other side'
1..8 | ForEach-Object { $lines += "    tx $(Hex 8) -> rx $(Hex 8)   ok" }
$lines += '[+] collection scheduled'
$lines += '[!] ETA: midnight'
$lines += "root@reaper:~# see you soon, $u"

foreach ($x in $lines) {
    if ($x -eq 'BAR') {
        0..20 | ForEach-Object {
            $bar = '    [' + ('#' * $_) + (' ' * (20 - $_)) + '] ' + ($_ * 5) + '%'
            $i = $term.Text.LastIndexOf([char]10)
            $term.Text = $term.Text.Substring(0, $i + 1) + $bar
            if ($_ -eq 0) { $term.AppendText([char]10) }
            $term.SelectionStart = $term.Text.Length; $term.ScrollToCaret()
            Start-Sleep -m 60; & $pump
        }
        $term.AppendText([char]10)
        continue
    }
    $term.AppendText($x + [char]10)
    $term.SelectionStart = $term.Text.Length; $term.ScrollToCaret()
    Start-Sleep -m $(if ($x.StartsWith('    ')) { 25 } else { 110 })
    & $pump
}
& $wait 1

# Finale
$term.Hide()
$fin = New-Object Windows.Forms.Label -Property @{ Dock=5; TextAlign=32; ForeColor='Red'; Font='Impact,120'; Text='SOUL ACQUIRED' }
$f.Controls.Add($fin)
& $wait $FinaleSeconds

$f.Close()
[Windows.Forms.Cursor]::Show()
