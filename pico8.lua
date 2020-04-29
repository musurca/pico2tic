--PICO-8 Wrapper for the TIC-80 Computer
--by @musurca
----------------------------------------
-- Wraps the PICO-8 API for ease of porting games
-- to the TIC-80. Favors compatibility over performance.
----------------------------------------
--known issues:
-- * swapping elements in the screen palette--e.g. pal(a,b,1)--doesn't work properly yet. However, pal(a,b) does work
-- * flip_x and flip_y are currently ignored in spr() and sspr()
-- * music() and flip() do nothing. sfx() does not take into account offset
-- * stat(1) always returns "0.5"

--set palette
PAL_PICO8="0000001D2B537E2553008751AB52365F574FC2C3C7FFF1E8FF004DFFA300FFEC2700E43629ADFF83769CFF77A8FFCCAA"
function PICO8_PALETTE()
	for i=0,15 do
		local r=tonumber(string.sub(PAL_PICO8,i*6+1,i*6+2),16)
		local g=tonumber(string.sub(PAL_PICO8,i*6+3,i*6+4),16)
		local b=tonumber(string.sub(PAL_PICO8,i*6+5,i*6+6),16)
		poke(0x3FC0+(i*3)+0,r)
		poke(0x3FC0+(i*3)+1,g)
		poke(0x3FC0+(i*3)+2,b)
	end	
end
PICO8_PALETTE()

--sound
__sfx=sfx
function sfx(n,channel,offset)
 --does not support offset as of 0.18.0
	if n<0 then
	 __sfx(0,28,channel,0)
	else
	 __sfx(0,28,channel)
	end
end

function music(n,fadems,channelmask)
 --do nothing as of 0.18.0
end

--utility
function stat(i)
 if i==0 then
	 return collectgarbage("count")
	end
 return 0.5
end

--strings
function sub(str,i,j)
 return str:sub(i,j)
end

--permanent cart mem
function cartdata(id)
 --do nothing
end

function dget(i)
 return pmem(i)
end

function dset(i,val)
 pmem(i,val)
end

--tables
count=table.getn

add=table.insert

function del(t,a)
 for i,v in ipairs(t) do
	 if v==a then
	  t[i]=t[#t]
	  t[#t]=nil
			return
		end
	end
end

--math
srand=math.randomseed
sqrt=math.sqrt
abs=math.abs
min=math.min
max=math.max
flr=math.floor
pi=math.pi

function rnd(a)
 a=a or 1
 return math.random()*a
end

function sgn(a)
 if a>=0 then return 1 end
	return -1
end

function cos(a)
 return math.cos(2*pi*a)
end

function sin(a)
 return -math.sin(2*pi*a)
end

function atan2(a,b)
 b=b or 1
 return math.atan(a,b)/(2*pi)
end

function mid(a,b,c)
 if a<=b and a<=c then return max(a,min(b,c))
	elseif b<=a and b<=c then return max(b,min(a,c)) end
	return max(c,min(a,b))
end

function band(a,b)
 return flr(a)&flr(b)
end

function bor(a,b)
 return flr(a)|flr(b)
end

function bxor(a,b)
 return flr(a)^flr(b)
end

function bnot(a,b)
 return flr(a)~flr(b)
end

function shl(a,b)
 return a<<b
end

function shr(a,b)
 return a>>b
end

--graphics
__p8_color=7
__p8_ctrans={true,false,false,false,false,false,false,false,
             false,false,false,false,false,false,false,false}
__p8_camera_x=0
__p8_camera_y=0
__p8_cursor_x=0
__p8_cursor_y=0
__p8_sflags={}
for i=1,256 do
 __p8_sflags[i]=0
end

function camera(cx,cy)
 cx=cx or 0
	cy=cy or 0
	__p8_camera_x=-flr(cx)
	__p8_camera_y=-flr(cy)
end

function cursor(cx,cy)
 cx=cx or 0
	cy=cy or 0
	__p8_cursor_x=flr(cx)
	__p8_cursor_y=flr(cy)
end

function __p8_coord(x,y)
 return flr(x+__p8_camera_x),
	       flr(y+__p8_camera_y)
end

__print=print
function print(str,x,y,c)
 x=x or __p8_cursor_x
	y=y or __p8_cursor_y
	c=c or __p8_color
	c=peek4(0x7FE0+c)
	__print(str,x,y,c)
	__p8_cursor_y=y+8
end

function color(c)
 c=c or 7
	__p8_color=flr(c%16)
end

function pal(c0,c1,type)
 c0=c0 or -1
	c1=c1 or -1
	type=type or 0
	
	if c0<0 and c1<0 then
	 if type==0 then
		 for i=0,15 do
		  poke4(0x7FE0+i,i)
		 end
		else
		 PICO8_PALETTE()
		end
	else
	 c0=flr(c0%16)
	 if c1<0 then
		 c1=c0
		end
		c1=flr(c1%16)
		if type==0 then
		 poke4(0x7FE0+c0,c1)
	 else
		 local stri
			for i=0,5 do
			 stri=#__p8_pal-(c1+1)*6+i
			 poke4(0x3FC0*2+#__p8_pal-(c0+1)*6+i,tonumber(__p8_pal:sub(stri,stri),16))
			end
		end
	end
end

function palt(c,trans)
 c=c or -1
	if c<0 then -- reset
	 __p8_ctrans[1]=true
		for i=2,16 do
		 __p8_ctrans[i]=false
		end
	else
	 __p8_ctrans[flr(c%16)+1]=trans
	end
end

function pset(x,y,c)
 c=c or __p8_color
	c=peek4(0x7FE0+c)
	x,y=__p8_coord(x,y)
 poke4(y*240+x,c) 	
end

function pget(x,y)
 x,y=__p8_coord(x,y)
	return peek4(y*240+x)
end

__rect=rect
function rectfill(x0,y0,x1,y1,c)
	c=c or __p8_color
	c=peek4(0x7FE0+c)
	x0,y0=__p8_coord(x0,y0)
	x1,y1=__p8_coord(x1,y1)
	local w,h=x1-x0,y1-y0
	__rect(x0,y0,w+sgn(w),h+sgn(h),c)
end

function rect(x0,y0,x1,y1,c)
 c=c or __p8_color
 c=peek4(0x7FE0+c)
	x0,y0=__p8_coord(x0,y0)
	x1,y1=__p8_coord(x1,y1)
	local w,h=x1-x0,y1-y0
	rectb(x0,y0,w+sgn(w),h+sgn(h),c) 
end

__circ=circ
function circfill(x,y,r,c)
 c=c or __p8_color
	c=peek4(0x7FE0+c)
	x,y=__p8_coord(x,y)
	__circ(x,y,r,c)
end

function circ(x,y,r,c)
 c=c or __p8_color
	c=peek4(0x7FE0+c)
	x,y=__p8_coord(x,y)
	circb(x,y,r,c)
end

__line=line
function line(x0,y0,x1,y1,c)
 c=c or __p8_color
 c=peek4(0x7FE0+c)
	x0,y0=__p8_coord(x0,y0)
	x1,y1=__p8_coord(x1,y1)
 __line(x0,y0,x1,y1,c)
end

function sspr(sx,sy,sw,sh,dx,dy,dw,dh) -- todo
 dw=dw or sw
	dh=dh or sh
 dx,dy=__p8_coord(dx,dy)
	if dx>240 or dy>136 then return end
	local xscale,yscale=dw/sw,dh/sh	
	local startx,starty,c=0,0
 if dx<0 then startx=-dx end
	if dy<0 then starty=-dy end
	if dx+dw>240 then dw=240-dx end
	if dy+dh>136 then dh=136-dy end
	for x=startx,dw-1 do
	 for y=starty,dh-1 do
		 c=sget(sx+x/xscale,sy+y/yscale)
			c=peek4(0x7FE0+c)
			if not __p8_ctrans[c+1] then
		  poke4((dy+y)*240+dx+x,c)
			end
		end
	end
end

__spr=spr
function spr(n,x,y,w,h) --todo flip_x,y
 w=w or 1
	h=h or 1
	local sx,sy,xoff,yoff=n%16*8,flr(n/16)*8,0,0
	for j=0,h-1 do
	 for i=0,w-1 do
	  sspr(sx+xoff,sy+yoff,8,8,x+xoff,y+yoff)
			--__spr(n+j*16+i,x+i*8,y+j*8,__p8_ctrans)
		 xoff=xoff+8
		end
		yoff=yoff+8
		xoff=0
	end
end

__map=map
function map(cel_x,cel_y,sx,sy,cel_w,cel_h)
 sx,sy=__p8_coord(sx,sy)
 local cel
	for cy=0,cel_h-1 do
	 for cx=0,cel_w-1 do
		 cel=mget(cx+cel_x,cy+cel_y)
			spr(cel,sx+cx*8,sy+cy*8)
		end
	end
	
	--__map(cel_x,cel_y,cel_w,cel_h,sx,sy,__p8_ctrans)
end
mapdraw=map

function sset(x,y,c) 
 x,y=flr(x),flr(y)
	local addr=0x8000+64*(flr(x/8)+flr(y/8)*16)
	poke4(addr+(y%8)*8+x%8,c)
end

function sget(x,y)
 x,y=flr(x),flr(y)
 local addr=0x8000+64*(flr(x/8)+flr(y/8)*16)
	return peek4(addr+(y%8)*8+x%8)
end

function flip()
 --do nothing
end

--sprite flags
function fset(n,f,v)
	if f>7 then
	 __p8_sflags[n+1]=f
	else	 
	 local flags=__p8_sflags[n+1]
	 if v then
	  flags=flags|(1<<f)
		else
		 flags=flags&~(1<<f)
		end
	 __p8_sflags[n+1]=flags	
	end
end

function fget(n,f)
 f=f or -1
	if f<0 then
	 return __p8_sflags[n+1]
	end
	local flags=__p8_sflags[n+1]
	if flags&(1<<f)>0 then return true end
	return false
end
