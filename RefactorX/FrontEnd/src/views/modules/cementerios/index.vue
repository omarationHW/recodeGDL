<template>
  <div class="module-dashboard">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
        </div>
        <div class="header-center">
          <h1>Sistema de Cementerios</h1>
          <p>Gestion de cementerios municipales</p>
        </div>
        <div class="header-right">
          <img src="/img/Innovacion_Gubernamental.png" alt="Innovacion Gubernamental" class="header-logo-right" />
        </div>
      </div>

      <div class="systems-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="cross" /></div>
          <h2>Modulos Disponibles</h2>
        </div>

        <div class="dashboard-grid">
          <div v-for="sec in sections" :key="sec.title" class="module-card">
            <div class="card-content">
              <div class="module-icon"><font-awesome-icon :icon="sec.icon" /></div>
              <h3 class="module-title">{{ sec.title }}</h3>
              <p class="module-description">{{ sec.desc }}</p>
            </div>
            <div class="card-links">
              <router-link v-for="link in sec.links" :key="link.to" :to="link.to" class="quick-link">
                {{ link.label }}
                <font-awesome-icon icon="chevron-right" class="link-arrow" />
              </router-link>
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
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome"

const sections = [
  { icon: 'file-alt', title: 'Titulos', desc: 'Registro de titulos de propiedad', links: [{ to: '/cementerios/titulos', label: 'Registro' }, { to: '/cementerios/consultafol', label: 'Consulta' }] },
      { icon: 'credit-card', title: 'Pagos', desc: 'Gestion de pagos y liquidaciones', links: [{ to: '/cementerios/abcpagos', label: 'Gestion' }, { to: '/cementerios/liquidaciones', label: 'Liquidaciones' }] },
      { icon: 'search', title: 'Consultas', desc: 'Busqueda de registros', links: [{ to: '/cementerios/consultanombre', label: 'Por Nombre' }, { to: '/cementerios/conindividual', label: 'Individual' }] },
      { icon: 'exchange-alt', title: 'Traslados', desc: 'Gestion de traslados', links: [{ to: '/cementerios/traslados', label: 'Gestion' }, { to: '/cementerios/trasladofol', label: 'Por Folio' }] },
      { icon: 'chart-bar', title: 'Reportes', desc: 'Estadisticas y movimientos', links: [{ to: '/cementerios/estad-adeudo', label: 'Estadisticas' }, { to: '/cementerios/list-mov', label: 'Movimientos' }] },
      { icon: 'cogs', title: 'Catalogos', desc: 'Administracion de catalogos', links: [{ to: '/cementerios/abcementer', label: 'Cementerios' }, { to: '/cementerios/abcrecargos', label: 'Recargos' }] }
]
</script>

<style scoped>
.module-dashboard {
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
.header-logo { height: 70px; width: auto; }

.header-center { flex: 1; text-align: center; padding: 0 2rem; }
.header-center h1 { color: #ea8215; font-size: 1.5rem; font-weight: 700; margin: 0; letter-spacing: -0.5px; }
.header-center p { color: #64748b; font-size: 0.9rem; margin: 0.25rem 0 0 0; }

.header-right { flex-shrink: 0; }
.header-logo-right { height: 50px; width: auto; }
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
  font-size: 1.15rem;
  font-weight: 700;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.25rem;
}

.module-card {
  background: white;
  border-radius: 1rem;
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
}

.module-icon {
  width: 52px;
  height: 52px;
  border-radius: 0.875rem;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 0.875rem;
  color: white;
  font-size: 1.3rem;
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
  margin: 0 0 0.4rem 0;
}

.module-description {
  color: #64748b;
  font-size: 0.8rem;
  margin: 0;
  line-height: 1.4;
}

.card-links {
  padding: 0.75rem 1rem;
  border-top: 1px solid #f1f5f9;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  background: #fafbfc;
}

.quick-link {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  color: #475569;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 500;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
}

.quick-link:hover {
  background: rgba(234, 130, 21, 0.1);
  color: #ea8215;
}

.link-arrow {
  font-size: 0.65rem;
  color: #94a3b8;
  transition: all 0.2s ease;
}

.quick-link:hover .link-arrow {
  color: #ea8215;
  transform: translateX(3px);
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

@media (max-width: 1200px) { .dashboard-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) {
  .dashboard-header { flex-direction: column; gap: 1rem; padding: 1.25rem; }
  .header-center { padding: 0; }
  .header-center h1 { font-size: 1.3rem; }
  .header-logo { height: 50px; }
  .dashboard-grid { grid-template-columns: 1fr; }
}
</style>
