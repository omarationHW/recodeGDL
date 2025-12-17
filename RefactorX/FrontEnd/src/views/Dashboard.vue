<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1 class="dashboard-title">Sistema Municipal de Guadalajara</h1>
      <p class="dashboard-subtitle">Seleccione el sistema al que desea acceder</p>
    </div>

    <div class="dashboard-grid">
      <div
        class="module-card"
        v-for="module in modules"
        :key="module.name"
        @click="navigateToModule(module)"
      >
        <div class="module-icon">
          <font-awesome-icon :icon="module.icon" />
        </div>
        <div class="module-content">
          <h3 class="module-title">{{ module.label }}</h3>
          <p class="module-description">{{ module.description }}</p>
          <span class="module-link">
            Acceder <font-awesome-icon icon="arrow-right" />
          </span>
        </div>
      </div>
    </div>

    <div class="dashboard-footer">
      <p>&copy; {{ currentYear }} Ayuntamiento de Guadalajara. Todos los derechos reservados.</p>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ref } from 'vue'

const router = useRouter()
const currentYear = ref(new Date().getFullYear())

const modules = [
  {
    name: 'mercados',
    label: 'Mercados',
    icon: 'store',
    loginPath: '/mercados/acceso',
    description: 'Gestión de mercados municipales'
  },
  {
    name: 'estacionamiento-publico',
    label: 'Estacionamiento Público',
    icon: 'car',
    loginPath: '/estacionamiento-publico/accesos',
    description: 'Control de estacionamientos públicos'
  },
  {
    name: 'cementerios',
    label: 'Cementerios',
    icon: 'cross',
    loginPath: '/cementerios/acceso',
    description: 'Gestión de cementerios municipales'
  },
  {
    name: 'aseo-contratado',
    label: 'Aseo Contratado',
    icon: 'broom',
    loginPath: '/aseo-contratado/acceso',
    description: 'Control de servicios de aseo'
  },
  {
    name: 'estacionamiento-exclusivo',
    label: 'Estacionamiento Exclusivo',
    icon: 'square-parking',
    loginPath: '/estacionamiento-exclusivo/acceso',
    description: 'Gestión de estacionamientos exclusivos'
  },
  {
    name: 'multas-reglamentos',
    label: 'Multas y Reglamentos',
    icon: 'file-contract',
    loginPath: '/multas-reglamentos/acceso',
    description: 'Administración de multas y reglamentos'
  },
  {
    name: 'otras-obligaciones',
    label: 'Otras Obligaciones',
    icon: 'file-lines',
    loginPath: '/otras-obligaciones/acceso',
    description: 'Gestión de otras obligaciones'
  },
  {
    name: 'padron-licencias',
    label: 'Padrón de Licencias',
    icon: 'id-card',
    loginPath: '/padron-licencias/acceso',
    description: 'Control de padrón y licencias'
  },
  {
    name: 'predial',
    label: 'Predial',
    icon: 'building',
    loginPath: '/predial/acceso',
    description: 'Sistema de impuesto predial'
  },
  {
    name: 'distribucion',
    label: 'Distribución',
    icon: 'truck',
    loginPath: '/distribucion/acceso',
    description: 'Control de distribución'
  }
]

const navigateToModule = (module) => {
  router.push(module.loginPath)
}
</script>

<style scoped>
.dashboard {
  min-height: calc(100vh - 140px);
  padding: var(--space-2xl, 2rem) var(--space-xl, 1.5rem);
  background: linear-gradient(135deg, var(--slate-50, #f8fafc) 0%, var(--slate-100, #f1f5f9) 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.dashboard-header {
  text-align: center;
  margin-bottom: var(--space-2xl, 2rem);
}

.dashboard-title {
  color: var(--municipal-primary, #ea8215);
  font-size: 2rem;
  font-weight: var(--font-weight-bold, 700);
  font-family: var(--font-heading, 'Seravek', 'Segoe UI', sans-serif);
  margin: 0 0 var(--space-sm, 0.75rem) 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.dashboard-subtitle {
  color: var(--slate-600, #475569);
  font-size: 1.1rem;
  font-weight: var(--font-weight-regular, 400);
  margin: 0;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: var(--space-lg, 1.25rem);
  max-width: 1800px;
  margin: 0 auto;
  justify-content: center;
  width: 100%;
  padding: var(--space-md, 1rem);
}

.module-card {
  background: white;
  border-radius: var(--radius-lg, 0.75rem);
  padding: var(--space-lg, 1.25rem);
  cursor: pointer;
  transition: all var(--transition-normal, 0.3s ease);
  box-shadow: var(--shadow-md, 0 4px 6px rgba(0, 0, 0, 0.07));
  border: 2px solid var(--slate-200, #e2e8f0);
  display: flex;
  flex-direction: row;
  align-items: center;
  text-align: left;
  position: relative;
  overflow: hidden;
  min-height: 100px;
  gap: var(--space-lg, 1.25rem);
}

.module-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--gradient-municipal, linear-gradient(135deg, #ea8215 0%, #cc9f52 100%));
  transform: scaleX(0);
  transition: transform var(--transition-normal, 0.3s ease);
}

.module-card:hover::before {
  transform: scaleX(1);
}

.module-card:hover {
  transform: translateY(-12px);
  box-shadow: var(--shadow-2xl, 0 25px 50px rgba(234, 130, 21, 0.25));
  border-color: var(--municipal-primary, #ea8215);
  background: linear-gradient(135deg, #ffffff 0%, #fff5eb 100%);
}

.module-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: var(--gradient-guadalajara, linear-gradient(135deg, #ea8215 0%, #cc9f52 100%));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all var(--transition-normal, 0.3s ease);
  box-shadow: 0 4px 12px rgba(234, 130, 21, 0.3);
}

.module-card:hover .module-icon {
  transform: scale(1.1) rotate(10deg);
  box-shadow: 0 8px 20px rgba(234, 130, 21, 0.4);
}

.module-icon svg {
  font-size: 1.5rem;
  color: white;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.module-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  gap: var(--space-xs, 0.375rem);
  width: 100%;
}

.module-title {
  color: var(--municipal-primary, #ea8215);
  font-size: 1.1rem;
  font-weight: var(--font-weight-bold, 700);
  font-family: var(--font-heading, 'Seravek', 'Segoe UI', sans-serif);
  margin: 0;
  line-height: 1.3;
}

.module-description {
  color: var(--slate-600, #475569);
  font-size: 0.85rem;
  margin: 0;
  line-height: 1.4;
  display: block;
  opacity: 0.85;
}

.module-link {
  color: var(--municipal-secondary, #cc9f52);
  font-weight: var(--font-weight-semibold, 600);
  font-size: 0.8rem;
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs, 0.5rem);
  margin-top: var(--space-xs, 0.25rem);
  transition: all var(--transition-normal, 0.3s ease);
}

.module-card:hover .module-link {
  color: var(--municipal-primary, #ea8215);
  gap: var(--space-sm, 0.75rem);
}

.module-link svg {
  transition: transform var(--transition-normal, 0.3s ease);
}

.module-card:hover .module-link svg {
  transform: translateX(4px);
}

/* Responsive */
@media (max-width: 1024px) {
  .dashboard-grid {
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: var(--space-md, 1rem);
  }
}

@media (max-width: 768px) {
  .dashboard {
    padding: var(--space-xl, 1.5rem) var(--space-lg, 1.25rem);
  }

  .dashboard-title {
    font-size: 1.75rem;
  }

  .dashboard-subtitle {
    font-size: 1rem;
  }

  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: var(--space-md, 1rem);
    max-width: 100%;
  }

  .module-card {
    padding: var(--space-md, 1rem);
    min-height: 90px;
    gap: var(--space-md, 1rem);
  }

  .module-icon {
    width: 50px;
    height: 50px;
  }

  .module-icon svg {
    font-size: 1.3rem;
  }

  .module-title {
    font-size: 1rem;
  }

  .module-description {
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .dashboard {
    padding: var(--space-lg, 1.25rem) var(--space-md, 1rem);
  }

  .dashboard-title {
    font-size: 1.5rem;
  }

  .dashboard-subtitle {
    font-size: 0.95rem;
  }

  .dashboard-grid {
    max-width: 100%;
  }

  .module-card {
    min-height: 85px;
    gap: var(--space-sm, 0.75rem);
    padding: var(--space-sm, 0.75rem);
  }

  .module-icon {
    width: 45px;
    height: 45px;
  }

  .module-icon svg {
    font-size: 1.15rem;
  }

  .module-title {
    font-size: 0.95rem;
  }

  .module-description {
    font-size: 0.75rem;
  }

  .module-link {
    font-size: 0.75rem;
  }
}

.dashboard-footer {
  margin-top: var(--space-3xl, 3rem);
  text-align: center;
  color: var(--slate-500, #64748b);
  font-size: 0.875rem;
  padding: var(--space-lg, 1.25rem);
}

.dashboard-footer p {
  margin: 0;
  font-weight: var(--font-weight-regular, 400);
}
</style>

