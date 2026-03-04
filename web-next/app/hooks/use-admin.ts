'use client';

import { FormEvent, useCallback, useState } from 'react';
import { MassSchedule, OfficeHour, User } from '../components/home-page.types';
import { API_BASE_URL, getAuthHeaders, parseResponse } from '../services/api';

type UseAdminParams = {
  user: User | null;
  sessionToken: string | null;
  loadPublicData: () => Promise<void>;
  onCurrentUserUpdated?: (nextUser: User) => void;
};

const SELF_TEST_EMAIL = 'usuario.teste@paroquia.local';

function canManageAdmin(user: User | null) {
  return user != null && user.nivelAcesso >= 3;
}

function canSelfAdjustOwnLevel(user: User | null, targetUserId: number) {
  return user != null && user.email === SELF_TEST_EMAIL && user.id === targetUserId;
}

export function useAdmin({ user, sessionToken, loadPublicData, onCurrentUserUpdated }: UseAdminParams) {
  const [busy, setBusy] = useState(false);
  const [usersManagement, setUsersManagement] = useState<User[]>([]);
  const [usersLoading, setUsersLoading] = useState(false);
  const [adminNotice, setAdminNotice] = useState<string | null>(null);

  const [newUserName, setNewUserName] = useState('');
  const [newUserEmail, setNewUserEmail] = useState('');
  const [newUserPassword, setNewUserPassword] = useState('');
  const [newUserLevel, setNewUserLevel] = useState(0);

  const [massWeekday, setMassWeekday] = useState(0);
  const [massTime, setMassTime] = useState('');
  const [massLocation, setMassLocation] = useState('');
  const [massNotes, setMassNotes] = useState('');

  const [officeWeekday, setOfficeWeekday] = useState(0);
  const [officeOpenTime, setOfficeOpenTime] = useState('');
  const [officeCloseTime, setOfficeCloseTime] = useState('');
  const [officeLabel, setOfficeLabel] = useState('Secretaria');
  const [officeNotes, setOfficeNotes] = useState('');

  const loadUsers = useCallback(async () => {
    if (!sessionToken || !canManageAdmin(user)) return;
    setUsersLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/users`, {
        headers: { authorization: `Bearer ${sessionToken}` },
        cache: 'no-store',
      });
      const data = await parseResponse<User[]>(response);
      setUsersManagement(data);
    } finally {
      setUsersLoading(false);
    }
  }, [sessionToken, user]);

  const onCreateUserByAdmin = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!sessionToken || !canManageAdmin(user)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/users`, {
        method: 'POST',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          nome: newUserName.trim(),
          email: newUserEmail.trim().toLowerCase(),
          senha: newUserPassword,
          nivelAcesso: Number(newUserLevel),
        }),
      });
      await parseResponse<User>(response);
      setNewUserName('');
      setNewUserEmail('');
      setNewUserPassword('');
      setNewUserLevel(0);
      setAdminNotice('Usuario criado com sucesso.');
      await loadUsers();
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao criar usuario.');
    } finally {
      setBusy(false);
    }
  }, [loadUsers, newUserEmail, newUserLevel, newUserName, newUserPassword, sessionToken, user]);

  const onUpdateUserAccessLevel = useCallback(async (targetUserId: number, level: number) => {
    if (!sessionToken) return;
    if (!canManageAdmin(user) && !canSelfAdjustOwnLevel(user, targetUserId)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/users/${targetUserId}/access-level`, {
        method: 'PATCH',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({ nivelAcesso: level }),
      });
      const updatedUser = await parseResponse<User>(response);
      if (user && updatedUser.id === user.id && onCurrentUserUpdated) {
        onCurrentUserUpdated(updatedUser);
      }
      await loadUsers();
      setAdminNotice('Nivel de acesso atualizado.');
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao atualizar usuario.');
    } finally {
      setBusy(false);
    }
  }, [loadUsers, onCurrentUserUpdated, sessionToken, user]);

  const onDeleteUser = useCallback(async (targetUserId: number) => {
    if (!sessionToken || !canManageAdmin(user)) return;
    if (!window.confirm('Deseja realmente excluir este usuario?')) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/users/${targetUserId}`, {
        method: 'DELETE',
        headers: { authorization: `Bearer ${sessionToken}` },
      });
      await parseResponse<{ message: string }>(response);
      await loadUsers();
      setAdminNotice('Usuario excluido com sucesso.');
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao excluir usuario.');
    } finally {
      setBusy(false);
    }
  }, [loadUsers, sessionToken, user]);

  const onCreateMassSchedule = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!sessionToken || !canManageAdmin(user)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/mass-schedules`, {
        method: 'POST',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          weekday: Number(massWeekday),
          time: massTime.trim(),
          locationName: massLocation.trim(),
          notes: massNotes.trim() || null,
          isActive: 1,
        }),
      });
      await parseResponse<MassSchedule>(response);
      setMassWeekday(0);
      setMassTime('');
      setMassLocation('');
      setMassNotes('');
      setAdminNotice('Horario de missa criado.');
      await loadPublicData();
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao criar horario de missa.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, massLocation, massNotes, massTime, massWeekday, sessionToken, user]);

  const onDeactivateMassSchedule = useCallback(async (id: number) => {
    if (!sessionToken || !canManageAdmin(user)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/mass-schedules/${id}/deactivate`, {
        method: 'PATCH',
        headers: { authorization: `Bearer ${sessionToken}` },
      });
      await parseResponse<{ message: string }>(response);
      setAdminNotice('Horario de missa desativado.');
      await loadPublicData();
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao desativar horario de missa.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, sessionToken, user]);

  const onCreateOfficeHour = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!sessionToken || !canManageAdmin(user)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/office-hours`, {
        method: 'POST',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          weekday: Number(officeWeekday),
          openTime: officeOpenTime.trim(),
          closeTime: officeCloseTime.trim() || null,
          label: officeLabel.trim() || 'Secretaria',
          notes: officeNotes.trim() || null,
          isActive: 1,
        }),
      });
      await parseResponse<OfficeHour>(response);
      setOfficeWeekday(0);
      setOfficeOpenTime('');
      setOfficeCloseTime('');
      setOfficeLabel('Secretaria');
      setOfficeNotes('');
      setAdminNotice('Horario da secretaria criado.');
      await loadPublicData();
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao criar horario da secretaria.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, officeCloseTime, officeLabel, officeNotes, officeOpenTime, officeWeekday, sessionToken, user]);

  const onDeactivateOfficeHour = useCallback(async (id: number) => {
    if (!sessionToken || !canManageAdmin(user)) return;
    setBusy(true);
    setAdminNotice(null);
    try {
      const response = await fetch(`${API_BASE_URL}/office-hours/${id}/deactivate`, {
        method: 'PATCH',
        headers: { authorization: `Bearer ${sessionToken}` },
      });
      await parseResponse<{ message: string }>(response);
      setAdminNotice('Horario da secretaria desativado.');
      await loadPublicData();
    } catch (error) {
      setAdminNotice(error instanceof Error ? error.message : 'Falha ao desativar horario da secretaria.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, sessionToken, user]);

  return {
    busy,
    usersManagement,
    usersLoading,
    adminNotice,
    newUserName,
    setNewUserName,
    newUserEmail,
    setNewUserEmail,
    newUserPassword,
    setNewUserPassword,
    newUserLevel,
    setNewUserLevel,
    massWeekday,
    setMassWeekday,
    massTime,
    setMassTime,
    massLocation,
    setMassLocation,
    massNotes,
    setMassNotes,
    officeWeekday,
    setOfficeWeekday,
    officeOpenTime,
    setOfficeOpenTime,
    officeCloseTime,
    setOfficeCloseTime,
    officeLabel,
    setOfficeLabel,
    officeNotes,
    setOfficeNotes,
    loadUsers,
    onCreateUserByAdmin,
    onUpdateUserAccessLevel,
    onDeleteUser,
    onCreateMassSchedule,
    onDeactivateMassSchedule,
    onCreateOfficeHour,
    onDeactivateOfficeHour,
  };
}
