<template>
  <div class="module-dashboard">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
        </div>
        <div class="header-center">
          <h1>Sistema de Mercados</h1>
          <p>Gestion integral de mercados municipales</p>
        </div>
        <div class="header-right">
          <img src="/img/Innovacion_Gubernamental.png" alt="Innovacion Gubernamental" class="header-logo-right" />
        </div>
      </div>

      <div class="systems-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="store" /></div>
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
  { icon: 'building', title: 'Padron Locales', desc: 'Gestion de locales comerciales', links: [{ to: '/mercados/localesmtto', label: 'Mantenimiento' }, { to: '/mercados/consultadatoslocales', label: 'Consulta' }] },
  { icon: 'bolt', title: 'Energia', desc: 'Control de energia electrica', links: [{ to: '/mercados/energiamtto', label: 'Mantenimiento' }, { to: '/mercados/consultadatosenergia', label: 'Consulta' }] },
  { icon: 'file-invoice-dollar', title: 'Adeudos', desc: 'Administracion de adeudos', links: [{ to: '/mercados/adeudoslocales', label: 'Locales' }, { to: '/mercados/adeudosenergia', label: 'Energia' }] },
  { icon: 'money-bill-wave', title: 'Pagos', desc: 'Registro de pagos', links: [{ to: '/mercados/altapagos', label: 'Alta Pagos' }, { to: '/mercados/conspagos', label: 'Consulta' }] },
  { icon: 'chart-bar', title: 'Reportes', desc: 'Estadisticas y reportes', links: [{ to: '/mercados/estadisticas', label: 'Estadisticas' }, { to: '/mercados/cuentapublica', label: 'Cuenta Publica' }] },
  { icon: 'cogs', title: 'Catalogos', desc: 'Configuracion del sistema', links: [{ to: '/mercados/catalogomercados', label: 'Mercados' }, { to: '/mercados/categoria', label: 'Categorias' }] }
]
</script>
