<template>
  <div class="module-dashboard">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
        </div>
        <div class="header-center">
          <h1>Aseo Contratado</h1>
          <p>Gestion de contratos de recoleccion de basura</p>
        </div>
        <div class="header-right">
          <img src="/img/Innovacion_Gubernamental.png" alt="Innovacion Gubernamental" class="header-logo-right" />
        </div>
      </div>

      <div class="systems-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="broom" /></div>
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
  { icon: 'file-contract', title: 'Contratos', desc: 'Gestion de contratos de aseo', links: [{ to: '/aseo-contratado/contratos', label: 'Consulta' }, { to: '/aseo-contratado/contratos-alta', label: 'Alta' }] },
  { icon: 'file-invoice-dollar', title: 'Adeudos', desc: 'Control de adeudos', links: [{ to: '/aseo-contratado/adeudos', label: 'Consulta' }, { to: '/aseo-contratado/adeudos-nvo', label: 'Generar' }] },
  { icon: 'money-bill-wave', title: 'Pagos', desc: 'Registro de pagos', links: [{ to: '/aseo-contratado/adeudos-pag', label: 'Pagos' }, { to: '/aseo-contratado/pagos-cons-cont', label: 'Consulta' }] },
  { icon: 'building', title: 'Empresas', desc: 'Catalogo de empresas', links: [{ to: '/aseo-contratado/abc-empresas', label: 'Gestion' }, { to: '/aseo-contratado/empresas-contratos', label: 'Por Contrato' }] },
  { icon: 'chart-bar', title: 'Reportes', desc: 'Estadisticas y reportes', links: [{ to: '/aseo-contratado/rpt-contratos', label: 'Contratos' }, { to: '/aseo-contratado/rpt-adeudos', label: 'Adeudos' }] },
  { icon: 'cogs', title: 'Catalogos', desc: 'Configuracion del sistema', links: [{ to: '/aseo-contratado/abc-zonas', label: 'Zonas' }, { to: '/aseo-contratado/abc-tipos-aseo', label: 'Tipos Aseo' }] }
]
</script>
