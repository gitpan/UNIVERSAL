#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/*
 * The main guts of traverse_isa was actually copied from gv_fetchmeth
 */

static SV *
isa_lookup(stash, name, len, level)
HV *stash;
char *name;
int len;
int level;
{
    AV* av;
    GV* gv;
    GV** gvp;
    HV* hv = Nullhv;

    if (!stash)
	return &sv_undef;

    if(strEQ(HvNAME(stash), name))
	return &sv_yes;

    if (level > 100)
	croak("Recursive inheritance detected");

    gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, FALSE);

    if (gvp && (gv = *gvp) != (GV*)&sv_undef && (hv = GvHV(gv))) {
	SV* sv;
	SV** svp = (SV**)hv_fetch(hv, name, len, FALSE);
	if (svp && (sv = *svp) != (SV*)&sv_undef)
	    return sv;
    }

    gvp = (GV**)hv_fetch(stash,"ISA",3,FALSE);
    
    if (gvp && (gv = *gvp) != (GV*)&sv_undef && (av = GvAV(gv))) {
	if(!hv) {
	    gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, TRUE);

	    gv = *gvp;

	    if (SvTYPE(gv) != SVt_PVGV)
		gv_init(gv, stash, "::ISA::CACHE::", 14, TRUE);

	    hv = GvHVn(gv);
	}
	if(hv) {
	    SV** svp = AvARRAY(av);
	    I32 items = AvFILL(av) + 1;
	    while (items--) {
		SV* sv = *svp++;
		HV* basestash = gv_stashsv(sv, FALSE);
		if (!basestash) {
		    if (dowarn)
			warn("Can't locate package %s for @%s::ISA",
			    SvPVX(sv), HvNAME(stash));
		    continue;
		}
		if(&sv_yes == isa_lookup(basestash, name, len, level + 1)) {
		    (void)hv_store(hv,name,len,&sv_yes,0);
		    return &sv_yes;
		}
	    }
	    (void)hv_store(hv,name,len,&sv_no,0);
	}
    }

    return &sv_no;
}

MODULE = UNIVERSAL		PACKAGE = UNIVERSAL

SV *
isa(sv, name)
SV *sv
char *name
PROTOTYPE: $$
CODE:
{
    char *s = "UNKNOWN";

    if (!SvROK(sv)) {
	ST(0) = &sv_no;
	return;
    }

    sv = (SV*)SvRV(sv);

    if(SvOBJECT(sv) &&
       &sv_yes == isa_lookup(SvSTASH(sv), name, strlen(name), 0)) {
	ST(0) = &sv_yes;
	return;
    }

    switch (SvTYPE(sv)) {
    	case SVt_NULL:
	case SVt_IV:
	case SVt_NV:
	case SVt_RV:
	case SVt_PV:
	case SVt_PVIV:
	case SVt_PVNV:
	case SVt_PVBM:
	case SVt_PVMG:	s = "SCALAR";		break;
	case SVt_PVLV:	s = "LVALUE";		break;
	case SVt_PVAV:	s = "ARRAY";		break;
	case SVt_PVHV:	s = "HASH";		break;
	case SVt_PVCV:	s = "CODE";		break;
	case SVt_PVGV:	s = "GLOB";		break;
	case SVt_PVFM:	s = "FORMATLINE";	break;
	case SVt_PVIO:	s = "FILEHANDLE";	break;
	default:	s = "UNKNOWN";		break;
    }

    ST(0) = strEQ(s,name) ? &sv_yes : &sv_no;
}

SV *
can(sv, name)
SV *sv
char *name
PROTOTYPE: $$
CODE:
{
    GV *gv;
    SV* rv = &sv_undef;
    CV *cv;

    if (!SvROK(sv)) {
       ST(0) = &sv_undef;
       return;
    }

    sv = (SV*)SvRV(sv);

    if(!SvOBJECT(sv)) {
       ST(0) = &sv_undef;
       return;
    }


    gv = gv_fetchmethod(SvSTASH(sv), name);

    if(gv && GvCV(gv)) {
        /* If the sub is only a stub then we may have a gv to AUTOLOAD */
    	GV **gvp = (GV**)hv_fetch(GvSTASH(gv), name, strlen(name), TRUE);
        if(gvp && (cv = GvCV(*gvp))) {
	    rv = sv_newmortal();
	    sv_setsv(rv, newRV((SV*)cv));
    	}
    }
    ST(0) = rv;
}


