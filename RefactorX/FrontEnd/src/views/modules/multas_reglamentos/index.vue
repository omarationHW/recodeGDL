<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gavel" /></div>
      <div class="module-view-info">
        <h1>Multas y Reglamentos</h1>
        <p>Seleccione una operación del módulo</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <ul>
            <li><router-link :to="{ name: 'multas-reglamentos-actualiza-fecha-empresas' }">Actualiza Fecha Empresas</router-link></li>
            <li><router-link :to="{ name: 'multas-reglamentos-aplica-sdos-favor' }">Aplica Saldos a Favor</router-link></li>
            <li><router-link :to="{ name: 'multas-reglamentos-catastro-dm' }">Catastro DM</router-link></li>
            <li><router-link :to="{ name: 'multas-reglamentos-consreq400' }">ConsReq400</router-link></li>
            <li><router-link :to="{ name: 'multas-reglamentos-reqtrans' }">ReqTrans</router-link></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Vista de índice del módulo
</script>

