Name:		%{proj_name}
Version:	%{proj_version}
Release:	%{proj_release}
Summary:	Windchill control script

Group:		Applications/Productivity
Packager:	Robin Coe <rcoe.javadev@gmail.com>

Source:		%{name}-%{version}-%{release}.tar.gz
BuildRoot:	%{_builddir}/%{name}-%{version}-%{release}-buildroot
Requires:   	telnet
Requires:	initscripts
Requires:	chkconfig

%description
set of scripts and functions that control Windchill

%define wc_home ptc/Windchill_10.1

%prep
%setup -c -n %{name}-%{version}-%{release}

%build

%install
%{__mkdir_p} %{buildroot}/etc/init.d
%{__mkdir_p} %{buildroot}/%{wc_home}
%{__install} -m 774 scripts/etc/init.d/wcappctl %{buildroot}/etc/init.d/
%{__install} -m 664 scripts/%{wc_home}/functions.bash %{buildroot}/%{wc_home}/
%{__install} -m 664 scripts/%{wc_home}/config.bash %{buildroot}/%{wc_home}/
%{__install} -m 664 scripts/%{wc_home}/README %{buildroot}/%{wc_home}/


%clean
%{__rm} -rf %{buildroot}

%post
if [ "$1" -eq "1" ]; then
	# On install ...
	chkconfig --add wcappctl
fi


%files
%defattr(-,root,root)
%doc /%{wc_home}/README
%config /%{wc_home}/config.bash
/%{wc_home}/functions.bash
/etc/init.d/wcappctl

%changelog
- initial release
