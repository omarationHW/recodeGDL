<template>
  <div v-if="isAuthenticated" class="user-info-container">
    <div class="user-details">
      <div class="user-avatar">
        <font-awesome-icon icon="user-circle" />
      </div>
      <div class="user-text">
        <div class="user-name">{{ usuario }}</div>
        <div class="user-meta">
          <span class="badge" :class="nivelClass">{{ nivelTexto }}</span>
          <span class="ejercicio">
            <font-awesome-icon icon="calendar" />
            {{ ejercicio }}
          </span>
        </div>
      </div>
    </div>
    <button @click="logout" class="btn-logout" title="Cerrar Sesión">
      <font-awesome-icon icon="sign-out-alt" />
    </button>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import sessionService from '@/services/sessionService';
import nivelesService from '@/services/nivelesService';
import { useToast } from 'vue-toastification';

const router = useRouter();
const toast = useToast();

// Datos de sesión
const isAuthenticated = computed(() => sessionService.isAuthenticated());
const usuario = computed(() => sessionService.getUsuario() || 'Usuario');
const nivel = computed(() => sessionService.getNivel());
const ejercicio = computed(() => sessionService.getEjercicio());

// Cargar catálogo de niveles al montar el componente
onMounted(async () => {
  await nivelesService.cargarNiveles();
});

// Texto y clase según nivel (usando servicio de niveles)
const nivelTexto = computed(() => {
  return nivelesService.getNombreNivelSync(nivel.value);
});

const nivelColor = computed(() => {
  return nivelesService.getColorNivelSync(nivel.value);
});

const nivelClass = computed(() => {
  const nivelValue = nivel.value;
  return {
    'badge-nivel-1': nivelValue === 1,
    'badge-nivel-2': nivelValue === 2,
    'badge-nivel-3': nivelValue === 3,
    'badge-nivel-4': nivelValue === 4,
    'badge-nivel-5': nivelValue === 5,
    'badge-nivel-6': nivelValue === 6,
    'badge-nivel-7': nivelValue === 7,
    'badge-nivel-9': nivelValue === 9
  };
});

// Logout
const logout = () => {
  if (confirm('¿Está seguro que desea cerrar sesión?')) {
    sessionService.clearSession();
    toast.success('Sesión cerrada correctamente');
    router.push('/mercados/acceso');
  }
};
</script>

<style scoped>
/* =================================================================================
   USER INFO - Componente de información de usuario con tema municipal
   ================================================================================= */

.user-info-container {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  padding: var(--space-sm) var(--space-md);
  background: var(--slate-50);
  border-radius: var(--radius-lg);
  border: 1px solid var(--slate-200);
}

.user-details {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  flex: 1;
}

.user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--gradient-municipal);
  color: white;
  font-size: 1.5rem;
}

.user-text {
  display: flex;
  flex-direction: column;
  gap: var(--space-xs);
}

.user-name {
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
  font-size: 0.95rem;
  font-family: var(--font-municipal);
}

.user-meta {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
  font-size: 0.85rem;
}

/* Badges de nivel */
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  font-size: 0.75rem;
  font-weight: var(--font-weight-bold);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-nivel-1 {
  background: linear-gradient(135deg, #dc3545, #c82333);
  color: white;
}

.badge-nivel-2 {
  background: linear-gradient(135deg, var(--municipal-primary), var(--municipal-secondary));
  color: white;
}

.badge-nivel-3 {
  background: linear-gradient(135deg, #28a745, #218838);
  color: white;
}

.badge-nivel-4 {
  background: linear-gradient(135deg, #17a2b8, #138496);
  color: white;
}

.badge-nivel-5 {
  background: linear-gradient(135deg, #6c757d, #5a6268);
  color: white;
}

.badge-nivel-6 {
  background: linear-gradient(135deg, #6c757d, #5a6268);
  color: white;
}

.badge-nivel-7 {
  background: linear-gradient(135deg, #95a5a6, #7f8c8d);
  color: white;
}

.badge-nivel-9 {
  background: linear-gradient(135deg, #343a40, #23272b);
  color: white;
}

.ejercicio {
  color: var(--slate-600);
  display: flex;
  align-items: center;
  gap: 4px;
}

/* Botón de logout */
.btn-logout {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: var(--radius-md);
  background: var(--slate-200);
  color: var(--slate-600);
  cursor: pointer;
  transition: var(--transition-normal);
  font-size: 1rem;
}

.btn-logout:hover {
  background: var(--municipal-danger);
  color: white;
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

/* Responsive */
@media (max-width: 768px) {
  .user-info-container {
    padding: var(--space-xs) var(--space-sm);
  }

  .user-name {
    font-size: 0.85rem;
  }

  .user-meta {
    font-size: 0.75rem;
  }

  .badge {
    font-size: 0.65rem;
    padding: 1px 6px;
  }
}
</style>
