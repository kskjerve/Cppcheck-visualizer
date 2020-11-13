<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:output method="text" />
    
    
    <xsl:template match="/">
        <xsl:text>digraph G {&#xa;</xsl:text>
        <xsl:call-template name="legend"/>
        <xsl:apply-templates select="//scopes/scope[@type='Global']" />
        
        <xsl:apply-templates select="//variables/var"/>
        <xsl:apply-templates 
            select="//tokenlist/token[@type='name' and not(@function) and not(@type-scope) and not(@variable) and not(@valueType-type)]"
            mode="nextsibling"
        />
        
        <xsl:apply-templates select="//tokenlist/token"/>
        <xsl:apply-templates select="//tokenlist/token" mode="comments"/>
        
        <xsl:text>}&#xa;</xsl:text>
    </xsl:template>

        
    <xsl:template match="scope">
        <xsl:variable name="scopeid" select="@id"/>
        
        <xsl:text>    subgraph &quot;cluster_</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>&quot; {&#xa;</xsl:text>
        <xsl:text>        label = "</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@className"/>
        <xsl:text>";&#xa;</xsl:text>

        <xsl:text>    subgraph &quot;cluster_</xsl:text>
        <xsl:value-of select="generate-id()"/>
        <xsl:text>&quot; {&#xa;</xsl:text>
        <xsl:text>        style=filled</xsl:text>
        <xsl:text>        color=lightgray</xsl:text>
        <xsl:text>        label = "Line </xsl:text>
        <xsl:value-of select="//tokenlist/token[@scope=$scopeid][2]/@linenr"/>
        
        <xsl:text>";&#xa;</xsl:text>
        
        <xsl:apply-templates select="//tokenlist/token[@scope=$scopeid and @str != '}' and @str != ']' and @str != ')']" mode="scopeid"/>
        <xsl:text>      }&#xa;</xsl:text>
        <xsl:text>      }&#xa;</xsl:text>
        
        <xsl:apply-templates select="//scopes/scope[@nestedIn = $scopeid]"></xsl:apply-templates>
    </xsl:template>

    
    <xsl:template match="var">
        <xsl:variable name="typeid" select="@typeStartToken"/>
        <xsl:variable name="typetoken" select="//tokenlist/token[@id=$typeid]"/>
        
        <xsl:if test="@nameToken != '0'">
            <xsl:call-template name="relation">
                <xsl:with-param name="from" select="@typeStartToken"/>
                <xsl:with-param name="to" select="@nameToken"/>
                <xsl:with-param name="attributes">[color=blue]</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    
    <xsl:template match="token" mode="scopeid">
        <xsl:text>        "</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>";&#xa;</xsl:text>                

        <xsl:if test="@str=';' and not(@astOperand1 or @astOperand2)">
            <xsl:text>      }&#xa;</xsl:text>
            <xsl:text>    subgraph &quot;cluster_</xsl:text>
            <xsl:value-of select="generate-id()"/>
            <xsl:text>&quot; {&#xa;</xsl:text>
            <xsl:text>        style=filled</xsl:text>
            <xsl:text>        color=lightgray</xsl:text>
            <xsl:text>        label = "Line </xsl:text>
            <xsl:value-of select="following-sibling::token[1]/@linenr"/>
            <xsl:text>";&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="token">
        <xsl:variable name="parentid" select="@astParent"/>
        <xsl:variable name="parent" select="//tokenlist/token[@id = $parentid]"/>

        <!--<xsl:if test="$parent and not($parent/@astOperand1) and not($parent/@astOperand2)">
            <xsl:text>parent-link</xsl:text>
            <xsl:call-template name="relation">
                <xsl:with-param name="from" select="@astParent"/>
                <xsl:with-param name="to" select="@id"/>
            </xsl:call-template>    
        </xsl:if>-->

        <xsl:if test="@astOperand1">
            <xsl:call-template name="relation">
                <xsl:with-param name="from" select="@id"/>
                <xsl:with-param name="to" select="@astOperand1"/>
                <xsl:with-param name="fromport" select="1"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="@astOperand2">
            <xsl:call-template name="relation">
                <xsl:with-param name="from" select="@id"/>
                <xsl:with-param name="to" select="@astOperand2"/>
                <xsl:with-param name="fromport" select="2"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="token" mode="nextsibling">
        <xsl:variable name="sibling" select="following-sibling::token[1]"/>
        <xsl:if test="not($sibling/@str=( ')', ']', '}' ))">
            <xsl:call-template name="relation">
                <xsl:with-param name="from" select="@id"/>
                <xsl:with-param name="to" select="$sibling/@id"/>
                <xsl:with-param name="attributes">[style=dashed]</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="token" mode="comments">
        <xsl:variable name="valueid" select="@values"/>
        <xsl:if test="@str != '}' and @str != ']' and @str != ')'">
            <xsl:text>  "</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>" [label="</xsl:text>
            <xsl:if test="@values or @astOperand1 or @astOperand2">
                <xsl:text>{</xsl:text>
            </xsl:if>
            
<!--            <xsl:if test="@variable">
                <xsl:value-of select="@linenr"/>
                <xsl:text>: </xsl:text>
            </xsl:if>-->
            
            <xsl:value-of select="replace(replace(replace(replace(translate(@str, '\&quot;', ''), '\]', '\\]'), '\{', '\\{'), '&lt;', '\\&lt;'), '&gt;', '\\&gt;')"/>
            
            <xsl:apply-templates select="//valueflow/values[@id = $valueid]/value"/>
            
            <xsl:if test="@astOperand1 or @astOperand2">
                <xsl:text>|{&lt;1&gt;1|&lt;2&gt;2}</xsl:text>
            </xsl:if>
            
            <xsl:if test="@values or @astOperand1 or @astOperand2">
                <xsl:text>}</xsl:text>
            </xsl:if>
            
            <xsl:text>" </xsl:text>
            
            <xsl:if test="@values or @astOperand1 or @astOperand2">
                <xsl:text>shape=record </xsl:text>
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="@type='name' and not(@function) and not(@variable)">
                    <xsl:text>style=filled fontcolor=blue fillcolor=cadetblue1 </xsl:text>
                </xsl:when>
                <xsl:when test="@type='name' and @function">
                    <xsl:text>style=filled fontcolor=darkgreen fillcolor=palegreen1 </xsl:text>
                </xsl:when>
                <xsl:when test="@type='name' and @variable">
                    <xsl:text>style=filled fontcolor=coral4 fillcolor=wheat </xsl:text>
                </xsl:when>
                <xsl:when test="@type='number'">
                    <xsl:text>style=filled fontcolor=red fillcolor=snow </xsl:text>
                </xsl:when>
                <xsl:when test="@type='string'">
                    <xsl:text>style=filled fontcolor=brown fillcolor=snow </xsl:text>
                </xsl:when>
                <xsl:when test="@type='op'">
                    <xsl:text>style=filled fillcolor=lightpink </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>style=filled fillcolor=lightblue </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:text>];&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>
    

    


    <!-- =============  Named templates ============= -->
    
    <xsl:template name="relation">
        <xsl:param name="from"/>
        <xsl:param name="to"/>
        <xsl:param name="fromport"/>
        <xsl:param name="attributes"/>
        
        <xsl:text>  "</xsl:text>
        <xsl:value-of select="$from"/>
        <xsl:if test="$fromport">
            <xsl:text>":"</xsl:text>
            <xsl:value-of select="$fromport"/>
        </xsl:if>        
        <xsl:text>" -> "</xsl:text>
        <xsl:value-of select="$to"/>
        <xsl:text>" </xsl:text>
        <xsl:value-of select="$attributes"/>
        <xsl:text>;&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template name="legend">
        <![CDATA[
  subgraph cluster_01 {
    node [shape=plaintext]
    label = "Legend";
    key [label=<<table border="0" cellpadding="2" cellspacing="0" cellborder="0">
      <tr><td align="right" port="i1">typeStartToken</td></tr>
      <tr><td align="right" port="i2">token</td></tr>
      </table>>]
    key2 [label=<<table border="0" cellpadding="2" cellspacing="0" cellborder="0">
      <tr><td port="i1">nameToken</td></tr>
      <tr><td port="i2">next sibling</td></tr>
      </table>>]
    key:i1:e -> key2:i1:w [color=blue]
    key:i2:e -> key2:i2:w [style=dashed]
    { rank="same"; key:i1:e;  key2:i1:w; }
  }
]]>
    </xsl:template>
</xsl:stylesheet>
