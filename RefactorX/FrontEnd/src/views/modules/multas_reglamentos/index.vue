<template>
  <div class="module-dashboard">
    <div class="dashboard-content">
      <div class="dashboard-header">
        <div class="header-left">
          <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="header-logo" />
        </div>
        <div class="header-center">
          <h1>Sistema de Multas y Reglamentos</h1>
          <p>Gestion integral de multas, requerimientos y sanciones</p>
        </div>
        <div class="header-right">
          <img src="/img/Innovacion_Gubernamental.png" alt="Innovacion Gubernamental" class="header-logo-right" />
        </div>
      </div>

      <div class="systems-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="gavel" /></div>
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
  {
    icon: 'file-alt',
    title: 'Requerimientos',
    desc: 'Gestion de requerimientos fiscales',
    links: [
      { to: '/multas-reglamentos/req-frm', label: 'Nuevo Requerimiento' },
      { to: '/multas-reglamentos/listareq', label: 'Lista de Requerimientos' },
      { to: '/multas-reglamentos/requerimientos-dm', label: 'Requerimientos DM' }
    ]
  },
  {
    icon: 'gavel',
    title: 'Multas',
    desc: 'Administracion de multas',
    links: [
      { to: '/multas-reglamentos/multasfrm', label: 'Registro de Multas' },
      { to: '/multas-reglamentos/multas-dm', label: 'Multas DM' },
      { to: '/multas-reglamentos/bloqueo-multa', label: 'Bloqueo de Multas' }
    ]
  },
  {
    icon: 'percent',
    title: 'Descuentos',
    desc: 'Gestion de descuentos y condonaciones',
    links: [
      { to: '/multas-reglamentos/otorgadescto', label: 'Otorgar Descuento' },
      { to: '/multas-reglamentos/autdescto', label: 'Autorizar Descuento' },
      { to: '/multas-reglamentos/imprime-desctos', label: 'Imprimir Descuentos' }
    ]
  },
  {
    icon: 'credit-card',
    title: 'Pagos',
    desc: 'Registro y consulta de pagos',
    links: [
      { to: '/multas-reglamentos/ligapago', label: 'Liga de Pago' },
      { to: '/multas-reglamentos/pagosmultfrm', label: 'Pagos de Multas' },
      { to: '/multas-reglamentos/pagos-espe', label: 'Pagos Especiales' }
    ]
  },
  {
    icon: 'coins',
    title: 'Saldos a Favor',
    desc: 'Gestion de saldos a favor',
    links: [
      { to: '/multas-reglamentos/sdosfavor-dm', label: 'Saldos Favor DM' },
      { to: '/multas-reglamentos/sol-sdos-favor', label: 'Solicitud' },
      { to: '/multas-reglamentos/aplica-sdos-favor', label: 'Aplicar Saldos' }
    ]
  },
  {
    icon: 'chart-bar',
    title: 'Reportes',
    desc: 'Estadisticas y reportes',
    links: [
      { to: '/multas-reglamentos/estadreq', label: 'Estado Requerimientos' },
      { to: '/multas-reglamentos/rep-oper', label: 'Reporte Operaciones' },
      { to: '/multas-reglamentos/repavance', label: 'Reporte Avance' }
    ]
  }
]
</script>
