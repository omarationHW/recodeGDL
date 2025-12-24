<template>
  <div class="dashboard">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
        </div>
        <div class="header-center">
          <h1>Sistema Municipal de Guadalajara</h1>
          <p>Portal de Sistemas de Recaudacion y Gestion</p>
        </div>
        <div class="header-right">
          <span class="header-badge">Gobierno Municipal</span>
        </div>
      </div>

      <div class="systems-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="th-large" /></div>
          <h2>Sistemas Disponibles</h2>
        </div>

        <div class="dashboard-grid">
          <div v-for="mod in modules" :key="mod.name" class="module-card" @click="navigateToModule(mod)">
            <div class="card-content">
              <div class="module-icon"><font-awesome-icon :icon="mod.icon" /></div>
              <h3 class="module-title">{{ mod.label }}</h3>
              <p class="module-description">{{ mod.description }}</p>
            </div>
            <div class="card-footer">
              <span class="module-link">Acceder</span>
              <font-awesome-icon icon="arrow-right" class="link-arrow" />
            </div>
          </div>
        </div>
      </div>
    </div>
    <footer class="dashboard-footer">
      <p>&copy; 2025 Ayuntamiento de Guadalajara. Todos los derechos reservados.</p>
    </footer>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import sessionService from '@/services/sessionService'

const router = useRouter()

const modules = [
  { name: 'mercados', label: 'Mercados', icon: 'store', path: '/login', description: 'Administracion de locales, cuotas y pagos de mercados municipales' },
  { name: 'cementerios', label: 'Cementerios', icon: 'cross', path: '/login', description: 'Control de fosas, titulos de propiedad y servicios funerarios' },
  { name: 'estacionamiento-publico', label: 'Est. Publico', icon: 'car', path: '/login', description: 'Gestion de parquimetros, folios y recaudacion en via publica' },
  { name: 'estacionamiento-exclusivo', label: 'Est. Exclusivo', icon: 'parking', path: '/login', description: 'Permisos y control de zonas de estacionamiento reservado' },
  { name: 'aseo-contratado', label: 'Aseo Contratado', icon: 'broom', path: '/login', description: 'Contratos de recoleccion de residuos y servicios de limpieza' },
  { name: 'multas-reglamentos', label: 'Multas', icon: 'gavel', path: '/login', description: 'Infracciones, sanciones y procedimientos administrativos' },
  { name: 'otras-obligaciones', label: 'Otras Obligaciones', icon: 'file-alt', path: '/login', description: 'Gruas, remolques y obligaciones fiscales diversas' },
  { name: 'padron-licencias', label: 'Licencias', icon: 'id-card', path: '/login', description: 'Registro y renovacion de licencias comerciales y permisos' }
]

const navigateToModule = (mod) => {
  // Limpiar sesion anterior antes de ir al login
  sessionService.clearSession()
  router.push(mod.path)
}
</script>

<style scoped>
.dashboard {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f1f5f9;
}

.dashboard-content {
  flex: 1;
  padding: 1.5rem 2rem;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

.dashboard-header {
  background: white;
  border-radius: 1rem;
  padding: 1rem 2rem;
  margin-bottom: 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
}

.header-left { flex-shrink: 0; }
.header-logo { height: 80px; width: auto; }

.header-center { flex: 1; text-align: center; padding: 0 2rem; }
.header-center h1 { color: #ea8215; font-size: 1.6rem; font-weight: 700; margin: 0; letter-spacing: -0.5px; }
.header-center p { color: #64748b; font-size: 0.9rem; margin: 0.25rem 0 0 0; }

.header-right { flex-shrink: 0; }
.header-badge {
  background: linear-gradient(135deg, #f59e0b, #ea8215);
  color: white;
  padding: 0.5rem 1.25rem;
  border-radius: 2rem;
  font-weight: 600;
  font-size: 0.8rem;
  box-shadow: 0 2px 8px rgba(234, 130, 21, 0.25);
}

.systems-section { margin-bottom: 2rem; }

.section-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.section-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #ea8215, #f59e0b);
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
}

.section-header h2 {
  color: #1e293b;
  font-size: 1.25rem;
  font-weight: 700;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.25rem;
}

.module-card {
  background: white;
  border-radius: 1rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.module-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(234, 130, 21, 0.15);
  border-color: #f59e0b;
}

.card-content {
  padding: 1.5rem 1.25rem 1rem;
  text-align: center;
  flex: 1;
}

.module-icon {
  width: 56px;
  height: 56px;
  border-radius: 0.875rem;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem;
  color: white;
  font-size: 1.4rem;
  background: linear-gradient(145deg, #f59e0b, #ea8215);
  box-shadow: 0 4px 12px rgba(234, 130, 21, 0.3);
  transition: transform 0.3s ease;
}

.module-card:hover .module-icon {
  transform: scale(1.08);
}

.module-title {
  color: #1e293b;
  font-size: 1rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
}

.module-description {
  color: #64748b;
  font-size: 0.8rem;
  margin: 0;
  line-height: 1.5;
}

.card-footer {
  padding: 0.875rem 1.25rem;
  border-top: 1px solid #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background: #fafbfc;
}

.module-link {
  color: #ea8215;
  font-weight: 600;
  font-size: 0.875rem;
}

.link-arrow {
  color: #ea8215;
  font-size: 0.75rem;
  transition: transform 0.3s ease;
}

.module-card:hover .link-arrow {
  transform: translateX(4px);
}

.dashboard-footer {
  background: white;
  border-top: 1px solid #e2e8f0;
  padding: 1.25rem;
  text-align: center;
}

.dashboard-footer p {
  color: #64748b;
  font-size: 0.85rem;
  margin: 0;
}

@media (max-width: 1200px) { .dashboard-grid { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 900px) { .dashboard-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) {
  .dashboard-header { flex-direction: column; gap: 1rem; padding: 1.25rem; }
  .header-center { padding: 0; }
  .header-center h1 { font-size: 1.3rem; }
  .header-logo { height: 45px; }
}
@media (max-width: 480px) { .dashboard-grid { grid-template-columns: 1fr; } }
</style>
