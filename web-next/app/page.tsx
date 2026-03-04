'use client';

import { useEffect, useState } from 'react';
import { AuthPanel, AuthenticatedArea, HomeHeader } from './components/home-page-view';
import { TabKey, User, WEEKDAY_OPTIONS } from './components/home-page.types';
import { useAdmin } from './hooks/use-admin';
import { useAuth } from './hooks/use-auth';
import { usePublicData } from './hooks/use-public-data';

function formatDateTime(value: string) {
  return new Date(value).toLocaleString('pt-BR');
}

function accessLevelLabel(level: number) {
  if (level === 3) return 'Administrativo';
  if (level === 2) return 'Coordenador';
  if (level === 1) return 'Membro pastoral';
  return 'Usuario padrao';
}

function canCreateContent(user: User | null) {
  return user != null && user.nivelAcesso >= 1;
}

function canManageAdmin(user: User | null) {
  return user != null && user.nivelAcesso >= 3;
}

export default function Home() {
  const [tab, setTab] = useState<TabKey>('dashboard');
  const [loading, setLoading] = useState(true);

  const auth = useAuth();
  const publicData = usePublicData({ sessionToken: auth.sessionToken });
  const restoreSession = auth.restoreSession;
  const loadPublicData = publicData.loadPublicData;
  const setAppError = publicData.setAppError;
  const currentUser = auth.user;

  const admin = useAdmin({
    user: currentUser,
    sessionToken: auth.sessionToken,
    loadPublicData,
    onCurrentUserUpdated: auth.setUser,
  });
  const adminLoadUsers = admin.loadUsers;

  useEffect(() => {
    let mounted = true;
    const run = async () => {
      setLoading(true);
      setAppError(null);
      try {
        await loadPublicData();
        await restoreSession(() => setTab('dashboard'));
      } catch (error) {
        if (mounted) {
          setAppError(error instanceof Error ? error.message : 'Falha ao carregar dados.');
        }
      } finally {
        if (mounted) setLoading(false);
      }
    };
    void run();
    return () => {
      mounted = false;
    };
  }, [loadPublicData, restoreSession, setAppError]);

  useEffect(() => {
    if (tab === 'usuarios' && canManageAdmin(currentUser)) {
      void adminLoadUsers();
    }
  }, [adminLoadUsers, currentUser, tab]);

  const busy = auth.busy || publicData.busy || admin.busy;

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-b from-rose-50 to-white px-4 py-10">
        <section className="mx-auto max-w-3xl rounded-2xl border bg-white p-6 shadow-sm">
          <p className="text-sm text-zinc-600">Carregando aplicacao web...</p>
        </section>
      </main>
    );
  }

  return (
    <div
      className={`relative min-h-screen ${
        auth.user ? 'bg-gradient-to-b from-rose-50 to-white' : 'bg-cover bg-center bg-no-repeat'
      }`}
      style={!auth.user ? { backgroundImage: "url('/img/IMAGEM%20DA%20PAROQUIA.jpeg')" } : undefined}
    >
      {!auth.user ? <div className="absolute inset-0 bg-white/65" /> : null}
      {auth.user ? <HomeHeader user={auth.user} accessLevelLabel={accessLevelLabel} /> : null}

      <main className={`relative mx-auto w-full max-w-6xl px-4 ${auth.user ? 'py-8' : 'py-12'}`}>
        {publicData.appError ? (
          <div className="mb-4 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
            {publicData.appError}
          </div>
        ) : null}

        {!auth.user ? (
          <AuthPanel
            authMode={auth.authMode}
            setAuthMode={auth.setAuthMode}
            registerName={auth.registerName}
            setRegisterName={auth.setRegisterName}
            email={auth.email}
            setEmail={auth.setEmail}
            password={auth.password}
            setPassword={auth.setPassword}
            authError={auth.authError}
            busy={auth.busy}
            onLogin={auth.onLogin}
            onRegister={auth.onRegister}
            onForgotPassword={auth.onForgotPassword}
          />
        ) : (
          <AuthenticatedArea
            tab={tab}
            setTab={setTab}
            user={auth.user}
            busy={busy}
            refreshToken={auth.refreshToken}
            canCreateContent={canCreateContent(auth.user)}
            canManageAdmin={canManageAdmin(auth.user)}
            formatDateTime={formatDateTime}
            accessLevelLabel={accessLevelLabel}
            news={publicData.news}
            events={publicData.events}
            filteredNews={publicData.filteredNews}
            filteredEvents={publicData.filteredEvents}
            massSchedules={publicData.massSchedules}
            officeHours={publicData.officeHours}
            nextMass={publicData.nextMass}
            groups={publicData.groups}
            filteredGroups={publicData.filteredGroups}
            missas={publicData.missas}
            onLogout={() => auth.onLogout(() => setTab('dashboard'))}
            newsTitle={publicData.newsTitle}
            setNewsTitle={publicData.setNewsTitle}
            newsSubtitle={publicData.newsSubtitle}
            setNewsSubtitle={publicData.setNewsSubtitle}
            newsBody={publicData.newsBody}
            setNewsBody={publicData.setNewsBody}
            newsCategory={publicData.newsCategory}
            setNewsCategory={publicData.setNewsCategory}
            newsImageUrl={publicData.newsImageUrl}
            setNewsImageUrl={publicData.setNewsImageUrl}
            newsExternalLink={publicData.newsExternalLink}
            setNewsExternalLink={publicData.setNewsExternalLink}
            newsHighlight={publicData.newsHighlight}
            setNewsHighlight={publicData.setNewsHighlight}
            newsParishNotice={publicData.newsParishNotice}
            setNewsParishNotice={publicData.setNewsParishNotice}
            eventName={publicData.eventName}
            setEventName={publicData.setEventName}
            eventLocal={publicData.eventLocal}
            setEventLocal={publicData.setEventLocal}
            eventType={publicData.eventType}
            setEventType={publicData.setEventType}
            eventDate={publicData.eventDate}
            setEventDate={publicData.setEventDate}
            eventDateEnd={publicData.eventDateEnd}
            setEventDateEnd={publicData.setEventDateEnd}
            eventDescription={publicData.eventDescription}
            setEventDescription={publicData.setEventDescription}
            eventImageUrl={publicData.eventImageUrl}
            setEventImageUrl={publicData.setEventImageUrl}
            eventSignupLink={publicData.eventSignupLink}
            setEventSignupLink={publicData.setEventSignupLink}
            eventCapacity={publicData.eventCapacity}
            setEventCapacity={publicData.setEventCapacity}
            onCreateNews={publicData.onCreateNews}
            onCreateEvent={publicData.onCreateEvent}
            onUpdateNews={publicData.onUpdateNews}
            onDeleteNews={publicData.onDeleteNews}
            onUpdateEvent={publicData.onUpdateEvent}
            onDeleteEvent={publicData.onDeleteEvent}
            onDuplicateEvent={publicData.onDuplicateEvent}
            newsSearch={publicData.newsSearch}
            setNewsSearch={publicData.setNewsSearch}
            eventsSearch={publicData.eventsSearch}
            setEventsSearch={publicData.setEventsSearch}
            groupsSearch={publicData.groupsSearch}
            setGroupsSearch={publicData.setGroupsSearch}
            globalSearch={publicData.globalSearch}
            setGlobalSearch={publicData.setGlobalSearch}
            globalResults={publicData.globalResults}
            categories={publicData.categories}
            newsCategoryFilter={publicData.newsCategoryFilter}
            setNewsCategoryFilter={publicData.setNewsCategoryFilter}
            eventTypeFilter={publicData.eventTypeFilter}
            setEventTypeFilter={publicData.setEventTypeFilter}
            parishNotice={publicData.parishNotice}
            mediaFolder={publicData.mediaFolder}
            setMediaFolder={publicData.setMediaFolder}
            mediaItems={publicData.mediaItems}
            mediaFile={publicData.mediaFile}
            setMediaFile={publicData.setMediaFile}
            onUploadMedia={publicData.onUploadMedia}
            onLoadMediaGallery={publicData.loadMediaGallery}
            adminNotice={admin.adminNotice}
            newUserName={admin.newUserName}
            setNewUserName={admin.setNewUserName}
            newUserEmail={admin.newUserEmail}
            setNewUserEmail={admin.setNewUserEmail}
            newUserPassword={admin.newUserPassword}
            setNewUserPassword={admin.setNewUserPassword}
            newUserLevel={admin.newUserLevel}
            setNewUserLevel={admin.setNewUserLevel}
            onCreateUserByAdmin={admin.onCreateUserByAdmin}
            usersLoading={admin.usersLoading}
            usersManagement={admin.usersManagement}
            onRefreshUsers={() => void admin.loadUsers()}
            onUpdateUserAccessLevel={admin.onUpdateUserAccessLevel}
            onDeleteUser={admin.onDeleteUser}
            massWeekday={admin.massWeekday}
            setMassWeekday={admin.setMassWeekday}
            massTime={admin.massTime}
            setMassTime={admin.setMassTime}
            massLocation={admin.massLocation}
            setMassLocation={admin.setMassLocation}
            massNotes={admin.massNotes}
            setMassNotes={admin.setMassNotes}
            onCreateMassSchedule={admin.onCreateMassSchedule}
            onDeactivateMassSchedule={admin.onDeactivateMassSchedule}
            officeWeekday={admin.officeWeekday}
            setOfficeWeekday={admin.setOfficeWeekday}
            officeOpenTime={admin.officeOpenTime}
            setOfficeOpenTime={admin.setOfficeOpenTime}
            officeCloseTime={admin.officeCloseTime}
            setOfficeCloseTime={admin.setOfficeCloseTime}
            officeLabel={admin.officeLabel}
            setOfficeLabel={admin.setOfficeLabel}
            officeNotes={admin.officeNotes}
            setOfficeNotes={admin.setOfficeNotes}
            onCreateOfficeHour={admin.onCreateOfficeHour}
            onDeactivateOfficeHour={admin.onDeactivateOfficeHour}
            weekdayOptions={WEEKDAY_OPTIONS}
          />
        )}
      </main>
    </div>
  );
}
