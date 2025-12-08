<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="broom" />
      </div>
      <div class="module-view-info">
        <h1>Aseo Contratado</h1>
        <p>Sistema de gestión de contratos de aseo público</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="quick-access-grid">
        <div class="quick-access-card">
          <div class="card-icon catalogos">
            <font-awesome-icon icon="list" />
          </div>
          <h3>Catalogos</h3>
          <p>Administracion de catalogos del sistema</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/empresas">Empresas</router-link>
            <router-link to="/aseo-contratado/tipos-aseo">Tipos de Aseo</router-link>
            <router-link to="/aseo-contratado/zonas">Zonas</router-link>
            <router-link to="/aseo-contratado/unidades-recoleccion">Unidades Recoleccion</router-link>
            <router-link to="/aseo-contratado/recaudadoras">Recaudadoras</router-link>
            <router-link to="/aseo-contratado/claves-operacion">Claves Operacion</router-link>
            <router-link to="/aseo-contratado/gastos">Gastos</router-link>
            <router-link to="/aseo-contratado/recargos">Recargos</router-link>
            <router-link to="/aseo-contratado/tipos-empresa">Tipos Empresa</router-link>
          </div>
        </div>

        <div class="quick-access-card">
          <div class="card-icon contratos">
            <font-awesome-icon icon="file-contract" />
          </div>
          <h3>Contratos</h3>
          <p>Gestion de contratos de aseo</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/contratos-alta">Alta Contratos</router-link>
            <router-link to="/aseo-contratado/contratos-consulta">Consulta</router-link>
            <router-link to="/aseo-contratado/contratos-mod">Modificacion</router-link>
            <router-link to="/aseo-contratado/contratos-baja">Baja</router-link>
            <router-link to="/aseo-contratado/contratos-cancela">Cancelacion</router-link>
            <router-link to="/aseo-contratado/contratos-cons-admin">Consulta Admin</router-link>
            <router-link to="/aseo-contratado/contratos-cons-dom">Consulta Domicilio</router-link>
            <router-link to="/aseo-contratado/empresas-contratos">Empresas-Contratos</router-link>
          </div>
        </div>

        <div class="quick-access-card">
          <div class="card-icon adeudos">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <h3>Adeudos</h3>
          <p>Gestion de adeudos y pagos</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/adeudos">Adeudos</router-link>
            <router-link to="/aseo-contratado/adeudos-nvo">Nuevo Adeudo</router-link>
            <router-link to="/aseo-contratado/adeudos-carga">Carga Adeudos</router-link>
            <router-link to="/aseo-contratado/adeudos-ins">Insertar</router-link>
            <router-link to="/aseo-contratado/adeudos-pag">Pagos</router-link>
            <router-link to="/aseo-contratado/adeudos-edocta">Estado Cuenta</router-link>
            <router-link to="/aseo-contratado/adeudos-est">Estadisticas</router-link>
            <router-link to="/aseo-contratado/contratos-adeudos">Contratos-Adeudos</router-link>
          </div>
        </div>

        <div class="quick-access-card">
          <div class="card-icon operaciones">
            <font-awesome-icon icon="cogs" />
          </div>
          <h3>Operaciones</h3>
          <p>Operaciones especiales</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/actcont-cr">Actualizacion CR</router-link>
            <router-link to="/aseo-contratado/aplica-multas">Aplicar Multas</router-link>
            <router-link to="/aseo-contratado/datos-convenio">Datos Convenio</router-link>
            <router-link to="/aseo-contratado/descuentos-pago">Descuentos Pago</router-link>
            <router-link to="/aseo-contratado/ejercicios-gestion">Ejercicios Gestion</router-link>
            <router-link to="/aseo-contratado/adeudos-mult-ins">Insercion Multiple</router-link>
            <router-link to="/aseo-contratado/adeudos-pag-mult">Pago Multiple</router-link>
          </div>
        </div>

        <div class="quick-access-card">
          <div class="card-icon reportes">
            <font-awesome-icon icon="chart-bar" />
          </div>
          <h3>Reportes</h3>
          <p>Reportes y consultas</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/rpt-adeudos">Adeudos</router-link>
            <router-link to="/aseo-contratado/rpt-pagos">Pagos</router-link>
            <router-link to="/aseo-contratado/rpt-estado-cuenta">Estado Cuenta</router-link>
            <router-link to="/aseo-contratado/rpt-contratos">Contratos</router-link>
            <router-link to="/aseo-contratado/rpt-empresas">Empresas</router-link>
            <router-link to="/aseo-contratado/rep-padron-contratos">Padron Contratos</router-link>
            <router-link to="/aseo-contratado/rep-recaudadoras">Recaudadoras</router-link>
            <router-link to="/aseo-contratado/relacion-contratos">Relacion Contratos</router-link>
          </div>
        </div>

        <div class="quick-access-card">
          <div class="card-icon consultas">
            <font-awesome-icon icon="search" />
          </div>
          <h3>Consultas</h3>
          <p>Consultas especializadas</p>
          <div class="card-links">
            <router-link to="/aseo-contratado/pagos-cons-cont">Consulta Contratos</router-link>
            <router-link to="/aseo-contratado/pagos-cons-cont-asc">Consulta ASC</router-link>
            <router-link to="/aseo-contratado/pagos-con-fpgo">Forma de Pago</router-link>
            <router-link to="/aseo-contratado/adeudos-cn-cond">Con Condonacion</router-link>
            <router-link to="/aseo-contratado/adeudos-opc-mult">Opciones Multiple</router-link>
            <router-link to="/aseo-contratado/adeudos-venc">Vencimientos</router-link>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal de Documentacion Tecnica -->
  <TechnicalDocsModal
    :show="showTechDocs"
    :componentName="'index'"
    :moduleName="'aseo_contratado'"
    @close="closeTechDocs"
  />

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    @close="closeDocumentation"
    title="Ayuda - Aseo Contratado"
  >
    <h3>Modulo Aseo Contratado</h3>
    <p>Sistema integral para la gestion de contratos de aseo publico, incluyendo:</p>
    <ul>
      <li>Gestion de contratos y empresas</li>
      <li>Control de adeudos y pagos</li>
      <li>Catalogos y configuracion del sistema</li>
      <li>Reportes y estadisticas</li>
      <li>Operaciones especiales y consultas</li>
    </ul>
  </DocumentationModal>
</template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>
